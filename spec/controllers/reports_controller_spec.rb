require 'User'

describe ReportsController, type: :controller do

  describe 'GET #show_activities_by_city' do
  
    it 'should print out something meaningful' do
      user1 = User.create!({name:'Adam', city:'Santa Cruz'})
      user2 = User.create!({name:'Jenna', city:'Tempe'})
      user3 = User.create!({name: 'Marshall', city: 'San Francisco'})
      user4 = User.create!({name: 'Greg', city: 'Santa Cruz'})
      post1 = Post.create!({user_id: user1.id, title:"How to program in c++", content:"Join the 21 day quick start course!"})
      post2 = Post.create!({user_id: user1.id, title:"Pictures of cats", content:" (=^・ｪ・^=)"})
      comment1 = Comment.create!({user_id: user2.id, post_id: post2.id, message: "I like your cats!"})
      comment2 = Comment.create!({user_id: user3.id, post_id: post2.id, message: "That looks more like a dog to me."})
       # post2 should get timestamp updated to here.
      comment3 = Comment.create!({user_id: user3.id, post_id: post1.id, message: "If you are trying to teach people, you should try to get them A's. kitten the bell curve!"})
      comment4 = Comment.create!({user_id: user2.id, post_id: post1.id, message: "@Marshall - I don't think Adam is talking about grades. Its got to be a code name for some sort of dance!"})
      post3 = Post.create!({user_id: user2.id, title:"Was raking leaves and found this", content:"It was a $1 bill! This is going straight toward my next c++ book."})
      comment5 = Comment.create!({user_id: user1.id, post_id: post1.id, message: 'There will be free pizza!'})
      comment6 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment5.id, message: 'we\'ll have drinks and chips as well'})
      comment7 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment6.id, message: '*bump*'})
      comment8 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment4.id, message: 'You and Marshall are even more so welcome to join =|'})
      comment9 = Comment.create!({user_id: user1.id, post_id: post1.id, comment_id: comment7.id, message: '**bump**'})
      comment10 = Comment.create!({user_id: user2.id, post_id: post3.id, message: 'It was rather muddy so I put it in the washer mashine.'})
      comment11 = Comment.create!({user_id: user2.id, post_id: post1.id, comment_id: comment6.id, message: 'Well, it got ripped up when I dried it so now I have to tape it back up. Its worth the effort though. I\ve been eyeing that c++ book for a while now.'})
      comment12 = Comment.create!({user_id: user4.id, post_id: post3.id, message: 'You can get a new one trading it in at the bank bud.'})
       # post3 should get timestamp updated to here
      comment13 = Comment.create!({user_id: user4.id, post_id: post1.id, message: 'What an awesome event. I hope you\'re in the same city!'})
       # post1 should get timestamp updated to here
        
      get :show_activities_by_city, city: 'Santa Cruz'
      
      predictions = [post2, comment5, comment6, comment7, comment8, comment9, comment12, comment13, post1]
      
      expect(response).to have_http_status(204)
      json = JSON.parse(response.body)
      expect(json).to be_a(Hash)
      expect(json['activities']).to be_a(Array)
      expect(json['activities'].length).to eq(predictions.length)
      
      predictions.each_index do |i|
        val = predictions[i]
        expect(json['activities'][i]).to be_a(Hash)
        if json['activities'][i]['type'] == 'comments'
          expect(json['activities'][i]['message']).to eq(val.message)
          expect(json['activities'][i]['links']).to be_a(Hash)
          expect(json['activities'][i]['links']['users']).to eq(val.user_id)
          expect(json['activities'][i]['links']['posts']).to eq(val.post_id)
        elsif json['activities'][i]['type'] == 'posts'
          expect(json['activities'][i]['title']).to eq(val.title)
          expect(json['activities'][i]['content']).to eq(val.content)
          expect(json['activities'][i]['links']).to be_a(Hash)
          expect(json['activities'][i]['links']['users']).to eq(val.user_id)
        else
          expect(json['activities'][i]['type']).to be_in(['comments', 'posts'])
        end
      end
      
        
    end
  
  end
  
end
