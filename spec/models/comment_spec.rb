require 'User'

describe Comment do

  it 'can be valid' do
    user = User.create!({name: 'Jake', city: 'Austin'})
    post = Post.create!({user_id: user.id, title: 'Say your greetings!', content: 'I\ll start. Hello world!'})
    comment1 = nil
    comment2 = nil
    
    expect{comment1 = Comment.create!({
      user_id: user.id, 
      post_id: post.id, 
      message: 'Bonjour Le Monde'
    })}.to_not raise_error
    expect{comment2 = Comment.create!({
      user_id: user.id, 
      post_id: post.id, 
      comment_id: comment1.id,
      message: 'Hallå Världen'
    })}.to_not raise_error
    
  end

  it 'is invalid if no or invalid post_id' do
    user = User.create!({name: 'Jake', city: 'Austin'})
    
    expect{Comment.create!({user_id: user.id, message: 'Bonjour Le Monde'})}.to raise_error
  end
  
  it 'is invalid if no or invalid user_id' do
    user = User.create!({name: 'Jake', city: 'Austin'})
    post = Post.create!({user_id: user.id, title: 'Say your greetings!', content: 'I\ll start. Hello world!'})
    
    expect{Comment.create!({post_id: post.id, message: 'Bonjour Le Monde'})}.to raise_error
  end
  
  it 'is invalid if parent comment is for different post' do
    user1 = User.create!({name:'Adam', city:'Santa Cruz'})
    post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
    post2 = Post.create!({title:"Was raking leaves and found this", content:"It was a $1 bill! This is going straight toward my next c++ book.", user_id: user1.id})
    comment1 = Comment.create!({user_id: user1.id, post_id: post1.id, message: 'There will be free pizza!'})
    
    expect{Comment.create!({
      post_id: post2.id, 
      comment_id: comment1.id, 
      user_id: User1.id, 
      message: 'I can bring some napkins.'
    })}.to raise_error
  end

  it 'generates valid JSON API output' do
    user1 = User.create!({name:'Adam', city:'Santa Cruz'})
    post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
    post2 = Post.create!({title:"Was raking leaves and found this", content:"It was a $1 bill! This is going straight toward my next c++ book.", user_id: user1.id})
    comment1 = Comment.create!({user_id: user1.id, post_id: post2.id, message: 'There will be free pizza!'})
    comment2 = Comment.create!({user_id: user1.id, post_id: post2.id, comment_id: comment1.id, message: 'I can bring some napkins.'})
  
    json = comment2.as_json_api
    expect(json[:id]).to eq(comment2.id)
    expect(json[:message]).to eq(comment2.message)
    expect(json[:created_at]).to eq(comment2.created_at)
    expect(json[:updated_at]).to eq(comment2.updated_at)
    expect(json[:links]).to be_a(Hash)
    expect(json[:links][:users]).to eq(user1.id)
    expect(json[:links][:posts]).to eq(post2.id)
    expect(json[:links][:comments]).to eq(comment1.id)
    
  end
end
