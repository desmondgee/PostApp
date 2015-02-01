require 'User'

RSpec.describe CommentsController, :type => :controller do

  #========# CREATE #========#
  describe 'POST #create' do
    context 'when given blank string' do
      it 'does nothing and returns 204 status' do
        len = Comment.count
        post :create
        
        # didn't see anything to create, so no change 204 status.
        expect(response).to have_http_status(204)
        expect(Comment.count).to eq(len)
      end
    end
    context 'when given json comments hash not properly nested under comments' do
      it 'does nothing and returns 204 status' do
        user1 = User.create!({name: 'Adam', city: 'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({user_id: user1.id, title:'Card twirling strategies', content: 'Two time world champion on card twirling here. Ask tips about how to twirl cards in the comments.'})
        
        len = Comment.count
        comment_params = {message:"Are you really the world champion? Prove it!", links:{post_id: post1.id.to_s, user_id: user2.id.to_s}}
        
        post :create, comment_params
        
        # didn't see anything to create, so no change 204 status.
        expect(response).to have_http_status(204)
        expect(Comment.count).to eq(len)
      end
    end
    context 'when given json comments hash with bad relational post id' do
      it 'does nothing and returns 404 status' do
        user1 = User.create!({name: 'Adam', city: 'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:'Card twirling strategies', content: 'Two time world champion on card twirling here. Ask tips about how to twirl cards in the comments.'})
        
        len = Comment.count
        comment_params = {comments: {message:"Card twirling is all the hype nowadays.", links:{post_id: (post1.id+1).to_s, user_id: user2.id.to_s}}}
        
        post :create, comment_params
        
        # Couldn't find post relation so 404 status.
        expect(response).to have_http_status(404)
        expect(Comment.count).to eq(len)
      end
    end
    context 'when given a single comment nested under comments' do
      it 'should create the comment' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:'How to program in c++', content:'Join the 21 day quick start course!'})
        
        len = Comment.count
        comment_params = {message:"If you are trying to teach people, you should try to get them A's. kitten the bell curve!", links:{posts: post1.id.to_s, users: user2.id.to_s}}
        post :create, {comments: comment_params}
        
        # Check database
        expect(Comment.count).to eq(len+1)
        comment = Comment.last
        expect(comment.message).to eq(comment_params[:message])
        expect(comment.post_id).to eq(post1.id)
        expect(comment.user_id).to eq(user2.id)
        
        # Check response
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['comments']).to_not be_a(Array)
        expect(json['comments']['id']).to_not be_nil
        expect(json['comments']['message']).to eq(comment_params[:message])
        expect(json['comments']['links']).to be_a(Hash)
        expect(json['comments']['links']['users']).to eq(user2.id)
        expect(json['comments']['links']['posts']).to eq(post1.id)
      end
      it 'should update updated_at on related post' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({user_id: user1.id, title:'How to program in c++', content:'Join the 21 day quick start course!'})
        
        comment_params = {
          links:{
            posts: post1.id,
            users: user1.id
          },
          message: "If you are trying to teach people, you should try to get them A's. kitten the bell curve!"
        }
        
        post :create, {comments: comment_params}
        
        expect(response).to have_http_status(201)
        expect(Post.last.updated_at).to be > post1.updated_at
      end
    end
    context 'when given a multiple comments nested under comments' do
      it 'should create all of the comments' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        
        len = Comment.count
        comment_params = {comments: [
          {message:"I like your cats!", links:{users: user2.id.to_s, posts: post2.id.to_s}},
          {message:"That looks more like a dog to me.", links:{users: user3.id.to_s, posts: post2.id.to_s}},
          {message:"If you are trying to teach people, you should try to get them A's. kitten the bell curve!", links:{users: user3.id.to_s, posts: post1.id.to_s}},
          {message:"@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!", links:{users: user2.id.to_s, posts: post1.id.to_s}}
        ]}
        post :create, comment_params
        
        # Check response
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['comments']).to be_a(Array)
        expect(json['comments'].length).to eq(4)
        expect(json['comments'][0]['id']).to_not be_nil
        expect(json['comments'][0]['message']).to eq(comment_params[:comments][0][:message])
        expect(json['comments'][0]['links']).to be_a(Hash)
        expect(json['comments'][0]['links']['users'].to_s).to eq(comment_params[:comments][0][:links][:users].to_s)
        expect(json['comments'][0]['links']['posts'].to_s).to eq(comment_params[:comments][0][:links][:posts].to_s)
        expect(json['comments'][1]['message']).to eq(comment_params[:comments][1][:message])
        expect(json['comments'][1]['links']).to be_a(Hash)
        expect(json['comments'][1]['links']['users'].to_s).to eq(comment_params[:comments][1][:links][:users].to_s)
        expect(json['comments'][1]['links']['posts'].to_s).to eq(comment_params[:comments][1][:links][:posts].to_s)
        expect(json['comments'][2]['message']).to eq(comment_params[:comments][2][:message])
        expect(json['comments'][2]['links']).to be_a(Hash)
        expect(json['comments'][2]['links']['users'].to_s).to eq(comment_params[:comments][2][:links][:users].to_s)
        expect(json['comments'][2]['links']['posts'].to_s).to eq(comment_params[:comments][2][:links][:posts].to_s)
        expect(json['comments'][3]['message']).to eq(comment_params[:comments][3][:message])
        expect(json['comments'][3]['links']).to be_a(Hash)
        expect(json['comments'][3]['links']['users'].to_s).to eq(comment_params[:comments][3][:links][:users].to_s)
        expect(json['comments'][3]['links']['posts'].to_s).to eq(comment_params[:comments][3][:links][:posts].to_s)
        
        # Check database
        expect(Comment.count).to eq(len+4)
        json['comments'].each do |jp|
          comment = Comment.find_by_id(jp['id'])
          expect(comment.message).to eq(jp['message'])
          expect(comment.user_id).to eq(jp['links']['users'])
          expect(comment.post_id).to eq(jp['links']['posts'])
        end
      end
      it 'should update post updated_at timestamps' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        
        comment_params = {comments: [
          {message:"I like your cats!", links:{users: user2.id.to_s, posts: post2.id.to_s}},
          {message:"That looks more like a dog to me.", links:{users: user3.id.to_s, posts: post2.id.to_s}},
          {message:"If you are trying to teach people, you should try to get them A's. kitten the bell curve!", links:{users: user3.id.to_s, posts: post1.id.to_s}},
          {message:"@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!", links:{users: user2.id.to_s, posts: post1.id.to_s}}
        ]}
        post :create, comment_params
        
        # Check response
        expect(response).to have_http_status(201)
        expect(Post.find(post1.id).updated_at).to be > post1.updated_at
        expect(Post.find(post2.id).updated_at).to be > post2.updated_at
      end
    end
    context 'when given a multiple comments, some with invalid relations' do
      it 'should create all of the comments' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        
        len = Comment.count
        comment_params = {comments: [
          {message:"I like your cats!", links:{users: user2.id.to_s, posts: post2.id.to_s}},
          {message:"That looks more like a dog to me.", links:{users: user3.id.to_s, posts: (post2.id+1).to_s}},
          {message:"If you are trying to teach people, you should try to get them A's. kitten the bell curve!", links:{users: (user3.id+1).to_s, posts: post1.id.to_s}},
          {message:"@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!", links:{users: user2.id.to_s, posts: post1.id.to_s}}
        ]}
        post :create, comment_params
        
        expect(response).to have_http_status(404)
        expect(Comment.count).to eq(len)
        
      end
    end
  end
  
  
  #========# SHOW #========#
  describe 'GET #show' do
    context 'when given a comment id not in database' do
      it 'should return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        
        get :show, ids: comment.id+1
        
        expect(response).to have_http_status(404)
      end
    end
    context 'when given a valid comment id' do
      it 'should return a valid json api json' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        
        get :show, ids: comment.id
        
        # Check response
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json['comments']).to_not be_a(Array)
        expect(json['comments']['message']).to eq(comment.message)
        expect(json['comments']['links']).to be_a(Hash)
        expect(json['comments']['links']['users']).to eq(user.id)
        expect(json['comments']['links']['posts']).to eq(post1.id)
        
      end
    end
    context 'when given multiple valid comment ids' do
      it 'should return a valid json api json' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        comment1 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "I like your cats!"})
        comment2 = Comment.create!({user_id: user3.id, post_id: post2.id, message: "That looks more like a dog to me."})
        comment3 = Comment.create!({user_id: user3.id, post_id: post1.id, message: "If you are trying to teach people, you should try to get them A's. kitten the bell curve!"})
        comment4 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!"})
        
        get :show, ids:[comment1.id,comment2.id,comment3.id].join(',')
        
        # Check response
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        comments = [comment1,comment2,comment3,comment4]
        expect(json['comments']).to be_a(Array)
        json['comments'].each_with_index do |val, i|
          expect(val['message']).to eq(comments[i].message)
          expect(val['links']).to be_a(Hash)
          expect(val['links']['users']).to eq(comments[i].user_id)
          expect(val['links']['posts']).to eq(comments[i].post_id)
        end
      end
    end
    
    context 'when given multiple comment ids, some invalid' do
      it 'should return a valid json api json' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        comment1 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "I like your cats!"})
        comment2 = Comment.create!({user_id: user3.id, post_id: post2.id, message: "That looks more like a dog to me."})
        comment3 = Comment.create!({user_id: user3.id, post_id: post1.id, message: "If you are trying to teach people, you should try to get them A's. kitten the bell curve!"})
        comment4 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!"})
        
        get :show, ids:[comment1.id,comment3.id,(comment4.id+1)].join(',')
        
        # Check response
        expect(response).to have_http_status(404)
      end
    end
  end
    
    
  #========# DELETE #========#
  describe 'DELETE #delete' do
    context 'when deleting on comment not in database' do
      it 'should return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        len = Comment.count
        
        delete :delete, ids: comment.id+1
        
        expect(response).to have_http_status(404)
        expect(Comment.count).to eq(len)
      end
    end
    context 'when deleting a comment in database' do
      it 'should delete the comment' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        len = Comment.count
        
        delete :delete, ids: comment.id
        
        expect(response).to have_http_status(204)
        expect(Comment.count).to eq(len-1)
      end
    end
    context 'when deleting multiple  comments in database, but not all valid' do
      it 'should delete the comment' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        len = Comment.count
        
        delete :delete, ids: [comment.id,43,52353].join(',')
        
        expect(response).to have_http_status(404)
        expect(Comment.count).to eq(len)
      end
    end
    context 'when deleting multiple valid comments in database' do
      it 'should delete the comment' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
        post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
        comment1 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "I like your cats!"})
        comment2 = Comment.create!({user_id: user3.id, post_id: post2.id, message: "That looks more like a dog to me."})
        comment3 = Comment.create!({user_id: user3.id, post_id: post1.id, message: "If you are trying to teach people, you should try to get them A's. kitten the bell curve!"})
        comment4 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!"})
        
        # Before state
        len = Comment.count
        expect(Comment.find_by_id(comment1.id)).to_not be_nil
        expect(Comment.find_by_id(comment2.id)).to_not be_nil
        expect(Comment.find_by_id(comment3.id)).to_not be_nil
        expect(Comment.find_by_id(comment4.id)).to_not be_nil
        
        # Deletion
        delete :delete, ids: [comment2.id,comment3.id].join(',')
        
        # After state
        expect(response).to have_http_status(204)
        expect(Comment.count).to eq(len-2)
        expect(Comment.find_by_id(comment1.id)).to_not be_nil
        expect(Comment.find_by_id(comment2.id)).to be_nil
        expect(Comment.find_by_id(comment3.id)).to be_nil
        expect(Comment.find_by_id(comment4.id)).to_not be_nil
        
      end
    end
    context 'when deleting a comment that has a reply thread' do
      it 'should delete all comments in that thread' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        post2 = Post.create!({title:"Was raking leaves and found this", content:"It was a $1 bill! This is going straight toward my next c++ book.", user_id: user1.id})
        comment1 = Comment.create!({user_id: user1.id, post_id: post1.id, message: 'There will be free pizza!'})
        comment2 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment1.id, message: 'we\'ll have drinks and chips as well'})
        comment3 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment2.id, message: '*bump*'})
        comment4 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment1.id, message: 'Is anybody out there?'})
        comment5 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment3.id, message: '**bump**'})
        comment6 = Comment.create!({user_id: user1.id, post_id: post2.id, message: 'It was rather muddy so I put it in the washer mashine.'})
        comment7 = Comment.create!({user_id: user1.id, post_id: post2.id, comment_id: comment6.id, message: 'Well, it got ripped up when I dried it so now I have to tape it back up. Its worth the effort though. I\ve been eyeing that c++ book for a while now.'})
        
        # Before state
        len = Comment.count
        
        # Deletion
        delete :delete, ids: comment1.id.to_s
        
        # After state
        expect(response).to have_http_status(204)
        expect(Comment.count).to eq(len-5)
        expect(Comment.find_by_id(comment1.id)).to be_nil
        expect(Comment.find_by_id(comment2.id)).to be_nil
        expect(Comment.find_by_id(comment3.id)).to be_nil
        expect(Comment.find_by_id(comment4.id)).to be_nil
        expect(Comment.find_by_id(comment5.id)).to be_nil
        expect(Comment.find_by_id(comment6.id)).to_not be_nil
        expect(Comment.find_by_id(comment7.id)).to_not be_nil
        
      end
    end
  end
  
  
  #========# UPDATE #========#
  describe 'PUT #update' do
    context 'when updating comment not in database' do
      it 'should not update anything return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        comment = Comment.create!({user_id: user.id, post_id: post1.id, message: 'There will be free pizza.'})
        
        put :update, {ids: comment.id+1, comments: {
          id: comment.id+1,
          message: "There will be free crackers and drinks!"
        }}
        
        expect(response).to have_http_status(404)
        expect(Comment.find_by_id(comment.id).message).to eq(comment.message)
        
      end
    end
    context 'when updating comment in database' do
      it 'should successfully update and return 204 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id:user1.id})
        post2 = Post.create!({title:'A rock is just a rock', content:'And a tree is just a tree', user_id:user2.id})
        comment1 = Comment.create!({user_id: user1.id, post_id: post1.id, message: "There will be free pizza."})
        comment2 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "Too bad. I'm allergic to cheese!"})
        comment3 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "And a troll is just a troll?"})
        comment4 = Comment.create!({user_id: user1.id, post_id: post2.id, message: "[this message was removed by an admin]"})
        
        put :update, {ids: comment2.id+1, comments: {
          id: comment4.id,
          content: 'Stop replacing my comments!!'
        }}
        
        expect(response).to have_http_status(204)
        # check if any messages changed
        expect(Comment.find_by_id(comment1.id).message).to eq(comment1.message)
        expect(Comment.find_by_id(comment2.id).message).to eq(comment2.message)
        expect(Comment.find_by_id(comment3.id).message).to eq(comment3.message)
        expect(Comment.find_by_id(comment4.id).message).to eq(comment4.message)
      end
    end
    context 'when updating multiple comments with some invalid' do
      it 'should successfully update and return 204 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id:user1.id})
        post2 = Post.create!({title:'A rock is just a rock', content:'And a tree is just a tree', user_id:user2.id})
        comment1 = Comment.create!({user_id: user1.id, post_id: post1.id, message: "There will be free pizza."})
        comment2 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "Too bad. I'm allergic to cheese!"})
        comment3 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "And a troll is just a troll?"})
        comment4 = Comment.create!({user_id: user1.id, post_id: post2.id, message: "[this message was removed by an admin]"})
        
        put :update, {ids: [comment2.id,103,comment3.id,487932].join(','), comments: [
          {id: comment2.id, message:'Order a non-dairy pizza and MAYBE i\'ll drop by'},
          {id: 103, message:'There be rabbits in them hills.'},
          {id: comment4.id, message:'Finally I am back!'},
          {id: 487932, message:'Don\t forget to cut them into fifths before boiling.'}
        ]}
        
        expect(response).to have_http_status(404)
        expect(Comment.find_by_id(comment1.id).message).to eq(comment1.message)
        expect(Comment.find_by_id(comment2.id).message).to eq(comment2.message)
        expect(Comment.find_by_id(comment3.id).message).to eq(comment3.message)
        expect(Comment.find_by_id(comment4.id).message).to eq(comment4.message)
      end
    end
    context 'when updating multiple valid comments' do
      it 'should successfully update and return 204 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id:user1.id})
        post2 = Post.create!({title:'A rock is just a rock', content:'And a tree is just a tree', user_id:user2.id})
        comment1 = Comment.create!({user_id: user1.id, post_id: post1.id, message: "There will be free pizza."})
        comment2 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "Too bad. I'm allergic to cheese!"})
        comment3 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "And a troll is just a troll?"})
        comment4 = Comment.create!({user_id: user1.id, post_id: post2.id, message: "[this message was removed by an admin]"})
        
        put :update, {ids: [comment2.id,comment4.id].join(','), comments: [
          {id: comment2.id, message:'Order a non-dairy pizza and MAYBE i\'ll drop by'},
          {id: comment4.id, message:'Finally I am back!'}
        ]}
        
        expect(response).to have_http_status(204)
        expect(Comment.find_by_id(comment1.id).message).to eq(comment1.message)
        expect(Comment.find_by_id(comment2.id).message).to eq('Order a non-dairy pizza and MAYBE i\'ll drop by')
        expect(Comment.find_by_id(comment3.id).message).to eq(comment3.message)
        expect(Comment.find_by_id(comment4.id).message).to eq('Finally I am back!')
      end
    end
  end


end
