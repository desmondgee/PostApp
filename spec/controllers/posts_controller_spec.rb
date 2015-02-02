require 'rails_helper'
require 'User'

RSpec.describe PostsController, :type => :controller do


  #========# CREATE #========#
  describe 'POST #create' do
    context 'when given blank string' do
      it 'does nothing' do
        len = Post.count
        post :create
        
        # didn't see anything to create, so no change 204 status.
        expect(response).to have_http_status(204)
        expect(Post.count).to eq(len)
      end
    end
    context 'when given json posts hash not properly nested under posts attribute' do
      it 'does nothing' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        len = Post.count
        post_params = {title:"How to program in c++", content:"Join the 21 day quick start course!", links:{user:user.id.to_s}}
        post :create, post_params
        
        # didn't see anything to create, so no change 204 status.
        expect(response).to have_http_status(204)
        expect(Post.count).to eq(len)
      end
    end
    context 'when given a single post nested under posts attribute' do
      it 'should create the post' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        len1 = Post.count
        post_params = {title:"How to program in c++", content:"Join the 21 day quick start course!", links:{users:user.id.to_s}}
        post :create, {posts: post_params}
        
        # Check database
        expect(User.count).to eq(len1+1)
        post = Post.last
        expect(post.title).to eq(post_params[:title])
        expect(post.content).to eq(post_params[:content])
        expect(post.user_id).to eq(user.id)
        
        # Check response
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['posts']).to_not be_a(Array)
        expect(json['posts']['id']).to_not be_nil
        expect(json['posts']['title']).to eq(post_params[:title])
        expect(json['posts']['content']).to eq(post_params[:content])
        expect(json['posts']['links']).to be_a(Hash)
        expect(json['posts']['links']['users']).to eq(user.id)
        expect(json['posts']['links']['images']).to be_a(Array)
        expect(json['posts']['links']['images'].length).to eq(0)
        expect(json['posts']['links']['comments']).to be_a(Array)
        expect(json['posts']['links']['comments'].length).to eq(0)
        
      end
    end
    context 'when given a multiple posts nested under posts attribute' do
      it 'should create all of the posts' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        
        len = Post.count
        post_params = {posts: [
          {title:"How to program in c++", content:"Join the 21 day quick start course!", links:{users:user1.id.to_s}},
          {title:"This morning I..", content:"Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.", links:{users:user2.id.to_s}},
          {title:"Pictures of cats", content:" (=^・ｪ・^=)", links:{users:user1.id.to_s}}
        ]}
        post :create, post_params
        
        # Check response
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['posts']).to be_a(Array)
        expect(json['posts'].length).to eq(3)
        expect(json['posts'][0]['title']).to eq(post_params[:posts][0][:title])
        expect(json['posts'][0]['content']).to eq(post_params[:posts][0][:content])
        expect(json['posts'][1]['title']).to eq(post_params[:posts][1][:title])
        expect(json['posts'][1]['content']).to eq(post_params[:posts][1][:content])
        expect(json['posts'][2]['title']).to eq(post_params[:posts][2][:title])
        expect(json['posts'][2]['content']).to eq(post_params[:posts][2][:content])
        
        # Check database
        expect(Post.count).to eq(len+3)
        json['posts'].each do |jp|
          post = Post.find_by_id(jp['id'])
          expect(post.title).to eq(jp['title'])
          expect(post.content).to eq(jp['content'])
        end
        
      end
    end
    context 'when given multiple posts, some with invalid user relation' do
      it 'should not create any and return 404 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        
        len = Post.count
        post_params = {posts: [
          {title:"How to program in c++", content:"Join the 21 day quick start course!", links:{users:user1.id.to_s}},
          {title:"This morning I..", content:"Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.", links:{users:user2.id.to_s}},
          {title:"Pictures of cats", content:" (=^・ｪ・^=)", links:{users: (user2.id+1).to_s}}
        ]}
        post :create, post_params
        
        # Check database
        expect(Post.count).to eq(len)
        
        # Check response
        expect(response).to have_http_status(404)
      end
    end
    
  end
  
  
  #========# SHOW #========#
  describe 'GET #show' do
    context 'when given a post id not in database' do
      it 'should return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        
        get :show, ids: post.id+1
        
        expect(response).to have_http_status(404)
      end
    end
    context 'when given a valid post id' do
      it 'should return a valid json api json' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        
        get :show, ids: 1
        
        # Check response
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json['posts']).to_not be_a(Array)
        expect(json['posts']['title']).to eq(post.title)
        expect(json['posts']['content']).to eq(post.content)
        expect(json['posts']['links']).to be_a(Hash)
        expect(json['posts']['links']['users']).to eq(user.id)
        
      end
    end
    context 'when given multiple valid post ids' do
      it 'should return a valid json api json' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        post2 = Post.create!({title:"This morning I..", content:"Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.", user_id: user2.id})
        post3 = Post.create!({title:"Pictures of cats", content:" (=^・ｪ・^=)", user_id: user1.id})
        
        get :show, ids:[post1.id,post2.id,post3.id].join(',')
        
        # Check response
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json['posts']).to be_a(Array)
        expect(json['posts'][0]['title']).to eq(post1.title)
        expect(json['posts'][0]['content']).to eq(post1.content)
        expect(json['posts'][0]['links']).to be_a(Hash)
        expect(json['posts'][0]['links']['users']).to eq(post1.user_id)
        expect(json['posts'][1]['title']).to eq(post2.title)
        expect(json['posts'][1]['content']).to eq(post2.content)
        expect(json['posts'][1]['links']).to be_a(Hash)
        expect(json['posts'][1]['links']['users']).to eq(post2.user_id)
        expect(json['posts'][2]['title']).to eq(post3.title)
        expect(json['posts'][2]['content']).to eq(post3.content)
        expect(json['posts'][2]['links']).to be_a(Hash)
        expect(json['posts'][2]['links']['users']).to eq(post3.user_id)
        
      end
    end
    context 'when given multiple posts, some invalid' do
      it 'should return a valid json api json' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        post2 = Post.create!({title:"This morning I..", content:"Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.", user_id: user2.id})
        post3 = Post.create!({title:"Pictures of cats", content:" (=^・ｪ・^=)", user_id: user1.id})
        
        get :show, ids:[post1.id,post2.id,post3.id,post3.id+1].join(',')
        
        # Check response
        expect(response).to have_http_status(404)
      end
    end
  end
    
    
  #========# DELETE #========#
  describe 'DELETE #delete' do
    context 'when deleting on post not in database' do
      it 'should return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        len = Post.count
        
        delete :delete, ids: post.id+1
        
        expect(response).to have_http_status(404)
        expect(Post.count).to eq(len)
      end
    end
    context 'when deleting a post in database' do
      it 'should delete the post' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        len = Post.count
        
        delete :delete, ids: post.id
        
        expect(response).to have_http_status(204)
        expect(Post.count).to eq(len-1)
      end
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
        delete :delete, ids: post1.id.to_s
        
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
    context 'when deleting multiple  posts in database, but not all valid' do
      it 'should delete the post' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        len = Post.count
        
        delete :delete, ids: [post.id,43,52353].join(',')
        
        expect(response).to have_http_status(404)
        expect(Post.count).to eq(len)
      end
    end
    context 'when deleting multiple valid posts in database' do
      it 'should delete the post' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        post2 = Post.create!({title:"This morning I..", content:"Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.", user_id: user2.id})
        post3 = Post.create!({title:"Pictures of cats", content:" (=^・ｪ・^=)", user_id: user1.id})
        post4 = Post.create!({title:"Found another cat!", content:">^..^<", user_id: user1.id})
        post5 = Post.create!({title:"Today at the park..", content:"Today at the park I saw someone who had a c++ book and blogging cat pictures! Its been a very weird day.", user_id: user2.id})
        
        # Before state
        len = Post.count
        expect(Post.find_by_id(post1.id)).to_not be_nil
        expect(Post.find_by_id(post2.id)).to_not be_nil
        expect(Post.find_by_id(post3.id)).to_not be_nil
        expect(Post.find_by_id(post4.id)).to_not be_nil
        expect(Post.find_by_id(post5.id)).to_not be_nil
        
        # Deletion
        delete :delete, ids: [post2.id,post3.id].join(',')
        
        # After state
        expect(response).to have_http_status(204)
        expect(Post.count).to eq(len-2)
        expect(Post.find_by_id(post1.id)).to_not be_nil
        expect(Post.find_by_id(post2.id)).to be_nil
        expect(Post.find_by_id(post3.id)).to be_nil
        expect(Post.find_by_id(post4.id)).to_not be_nil
        expect(Post.find_by_id(post5.id)).to_not be_nil
        
      end
    end

  end
  
  
  #========# UPDATE #========#
  describe 'PUT #update' do
    context 'when updating post not in database' do
      it 'should not update anything return 404 status' do
        user = User.create!({name:'Adam', city:'Santa Cruz'})
        post = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id:user.id})
        
        put :update, {ids: post.id+1, posts: {
          id: post.id+1,
          title: "Lisp users rock!"
        }}
        
        expect(response).to have_http_status(404)
        expect(Post.find_by_id(post.id).title).to eq(post.title)
        
      end
    end
    context 'when updating post in database' do
      it 'should successfully update and return 204 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name: 'Marshall', city: 'San Francisco'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id:user1.id})
        post2 = Post.create!({title:'A rock is just a rock', content:'And a tree is just a tree', user_id:user2.id})
        
        put :update, {ids: post2.id+1, posts: {
          id: post2.id,
          content: 'But a tree may be a tree.. or it may be an ogre ninja'
        }}
        
        expect(response).to have_http_status(204)
        post1b = Post.find_by_id(post1.id)
        expect(post1b.title).to eq(post1.title)
        expect(post1b.content).to eq(post1.content)
        post2b = Post.find_by_id(post2.id)
        expect(post2b.title).to eq(post2.title)
        expect(post2b.content).to_not eq(post2.content)
      end
    end
    context 'when updating multiple valid posts in database' do
      it 'should successfully update and return 204 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id: user1.id})
        post2 = Post.create!({title:'This morning I..', content:'Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.', user_id: user2.id})
        post3 = Post.create!({title:'Pictures of cats', content:' (=^・ｪ・^=)', user_id: user1.id})
        post4 = Post.create!({title:'Found another cat!', content:'>^..^<', user_id: user1.id})
        post5 = Post.create!({title:'Today at the park..', content:'Today at the park I saw someone who had a c++ book and blogging cat pictures! Its been a very weird day.', user_id: user2.id})
        
        put :update, {ids: [post2.id,103,post3.id,487932].join(','), posts: [
          {id: post2.id, title:'This evening I..'},
          {id: post3.id, title:'Pictures of dogs'}
        ]}
        
        expect(response).to have_http_status(204)
        expect(Post.find_by_id(post1.id).title).to eq(post1.title)
        expect(Post.find_by_id(post2.id).title).to eq('This evening I..')
        expect(Post.find_by_id(post3.id).title).to eq('Pictures of dogs')
        expect(Post.find_by_id(post4.id).title).to eq(post4.title)
        expect(Post.find_by_id(post5.id).title).to eq(post5.title)
      end
    end
    context 'when updating multiple posts with some invalid' do
      it 'should rollback all updates and return 404 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id: user1.id})
        post2 = Post.create!({title:'This morning I..', content:'Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.', user_id: user2.id})
        post3 = Post.create!({title:'Pictures of cats', content:' (=^・ｪ・^=)', user_id: user1.id})
        post4 = Post.create!({title:'Found another cat!', content:'>^..^<', user_id: user1.id})
        post5 = Post.create!({title:'Today at the park..', content:'Today at the park I saw someone who had a c++ book and blogging cat pictures! Its been a very weird day.', user_id: user2.id})
        
        put :update, {ids: [post2.id,103,post3.id,487932].join(','), posts: [
          {id: post2.id, title:'This evening I..'},
          {id: 103, title:'Sign tossing 101'},
          {id: post3.id, title:'Pictures of dogs'},
          {id: 487932, title:'10 best stone skipping tricks'}
        ]}
        
        expect(response).to have_http_status(404)
        expect(Post.find_by_id(post1.id).title).to eq(post1.title)
        expect(Post.find_by_id(post2.id).title).to eq(post2.title)
        expect(Post.find_by_id(post3.id).title).to eq(post3.title)
        expect(Post.find_by_id(post4.id).title).to eq(post4.title)
        expect(Post.find_by_id(post5.id).title).to eq(post5.title)
      end
    end
  end
  
  #========# LIST #========#
  describe 'GET #list' do
    context 'no posts in database' do
      it 'should return an empty posts array' do
        get :list
        
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json).to be_a(Array)
        expect(json.length).to eq(0)
      end
    end
    context 'less than 20 posts in database' do
      it 'should return a posts array will all current posts' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id: user1.id})
        post2 = Post.create!({title:'This morning I..', content:'Had a breakfast burrito and it was amazing. My mouth is still watering from the perfect blend of eggs, salsa and hashbrown.', user_id: user2.id})
        post3 = Post.create!({title:'Pictures of cats', content:' (=^・ｪ・^=)', user_id: user1.id})
        image1 = Image.create!({post_id: post1.id, src: 'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'})
        image2 = Image.create!({post_id: post1.id, src: 'http://upload.wikimedia.org/wikipedia/commons/d/d2/Ime_slike.jpg'})
        image3 = Image.create!({post_id: post2.id, src: 'https://upload.wikimedia.org/wikipedia/commons/d/d6/Beispiel.png'})
        image4 = Image.create!({post_id: post3.id, src: 'https://upload.wikimedia.org/wikipedia/commons/e/ee/Example-zh.jpg'})
      
        get :list
        
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json).to be_a(Array)
        expect(json.length).to eq(3)
        
        expect(json[0]['title']).to eq(post1.title)
        expect(json[0]['content']).to eq(post1.content)
        expect(json[0]['author_name']).to eq(user1.name)
        expect(json[0]['author_city']).to eq(user1.city)
        expect(json[0]['image_urls']).to be_a(Array)
        expect(json[0]['image_urls'].length).to eq(2)
        expect(json[0]['image_urls'][0]).to eq(image1.src)
        expect(json[0]['image_urls'][1]).to eq(image2.src)
        
        expect(json[1]['title']).to eq(post2.title)
        expect(json[1]['content']).to eq(post2.content)
        expect(json[1]['author_name']).to eq(user2.name)
        expect(json[1]['author_city']).to eq(user2.city)
        expect(json[1]['image_urls']).to be_a(Array)
        expect(json[1]['image_urls'].length).to eq(1)
        expect(json[1]['image_urls'][0]).to eq(image3.src)
        
        expect(json[2]['title']).to eq(post3.title)
        expect(json[2]['content']).to eq(post3.content)
        expect(json[2]['author_name']).to eq(user1.name)
        expect(json[2]['author_city']).to eq(user1.city)
        expect(json[2]['image_urls']).to be_a(Array)
        expect(json[2]['image_urls'].length).to eq(1)
        expect(json[2]['image_urls'][0]).to eq(image4.src)
      end
    end
    context 'more than 20 posts in database' do
      it 'should get last 20 posts' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        user2 = User.create!({name:'Jenna', city:'Tempe'})
        user_ids = [user1.id,user2.id]
        
        post1 = nil
        post20 = nil
        
        50.times do |i|
          title = (0...8).map { (65 + rand(26)).chr }.join
          content = (0...50).map { (65 + rand(26)).chr }.join
          postn = Post.create!({user_id: user_ids.sample, title: title, content: content})
          if i == 30
            post1 = postn
          elsif i == 49
            post20 = postn
          end
        end
        
        get :list
        
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json).to be_a(Array)
        expect(json.length).to eq(20)
        
        expect(json[0]['title']).to eq(post1.title)
        expect(json[0]['content']).to eq(post1.content)
        expect(json[0]['author_name']).to eq(post1.user.name)
        expect(json[0]['author_city']).to eq(post1.user.city)
        expect(json[19]['title']).to eq(post20.title)
        expect(json[19]['content']).to eq(post20.content)
        expect(json[19]['author_name']).to eq(post20.user.name)
        expect(json[19]['author_city']).to eq(post20.user.city)
      end
    end
  end
  
  #========# SHOW COMMENTS #========#
  
  describe 'GET #show_comments' do
    context 'post not in database' do
      it 'should return 404 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id: user1.id})
        
        get :show_comments, {id: (post1.id+1).to_s}
        
        expect(response).to have_http_status(404)
      end
    end
    context 'valid post with no comments' do
      it 'should return empty comments array' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:'How to program in c++', content:'Join the 21 day quick start course!', user_id: user1.id})
        
        get :show_comments, {id: (post1.id).to_s}
        
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json['comments']).to be_a(Array)
        expect(json['comments'].length).to eq(0)
      end
    end
    context 'valid post with nested comments' do
      it 'should return comments array' do
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
        
        get :show_comments, {id: (post1.id).to_s}
        
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json['comments']).to be_a(Array)
        expect(json['comments'].length).to eq(5)
        expect(json['comments'][0]['message']).to eq(comment1.message)
        expect(json['comments'][1]['message']).to eq(comment2.message)
        expect(json['comments'][2]['message']).to eq(comment3.message)
        expect(json['comments'][3]['message']).to eq(comment4.message)
        expect(json['comments'][4]['message']).to eq(comment5.message)
      end
    end
    
  end
  
end
