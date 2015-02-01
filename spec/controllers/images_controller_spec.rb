require 'User'

describe ImagesController, type: :controller do

  describe 'POST #create' do
    context 'when incorrect json format, not putting properties under images' do
      it 'should return 404 status' do
        user1 = User.create!({name: 'Adam', city: 'Santa Cruz'})
        post1 = Post.create!({title: "How to program in c++", content: "Join the 21 day quick start course!", user_id: user1.id})
        image_params = {post_id: post1.id.to_s, src:'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'}
        len = Image.count
        
        post :create, image_params
        
        expect(Image.count).to eq(len)
        expect(response).to have_http_status(404)
      end
    end
    context 'when relational post is not valid or not present' do
      it 'should return 404 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        image_params = {post_id: (post1.id+1).to_s, src:'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'}
        len = Image.count
        
        post :create, {images: image_params}
        
        expect(Image.count).to eq(len)
        expect(response).to have_http_status(404)
      end
    end
    context 'when valid' do
      it 'should return 201 status with new image data in JSON API format' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        image_params = {links: {posts:(post1.id).to_s}, src:'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'}
        len = Image.count
        
        post :create, {images: image_params}
        
        expect(Image.count).to eq(len+1)
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json['images']).to be_a(Hash)
        expect(json['images']['src']).to eq('http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg')
        expect(json['images']['links']).to be_a(Hash)
        expect(json['images']['links']['posts']).to eq(post1.id)
      end
    end
  end
  
  describe 'DELETE #delete' do
    context 'given an image id not in database' do
      it 'should return 404 status' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        image1 = Image.create!({post_id: post1.id, src:'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'})
        len = Image.count
        
        post :delete, id: image1.id+1
        
        expect(Image.count).to eq(len)
        expect(response).to have_http_status(404)
      end
    end
    context 'given a valid image id' do
      it 'should return the url for that image wrapped in correct JSON API' do
        user1 = User.create!({name:'Adam', city:'Santa Cruz'})
        post1 = Post.create!({title:"How to program in c++", content:"Join the 21 day quick start course!", user_id: user1.id})
        image1 = Image.create!({post_id: post1.id, src:'http://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg'})
        len = Image.count
        
        post :delete, id: image1.id
        
        expect(Image.count).to eq(len-1)
        expect(response).to have_http_status(204)
      end
    end
  end
  
end
