
describe UsersController, type: :controller do
  describe 'GET #index' do
    context 'when no users have been created' do
      it 'should be JSON API format and give 204 status' do
        get :index
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json['users']).to be_a(Array)
        expect(json['users'].length).to eq(0)
      end
    end
    context 'when a few users in db' do
      before do
        User.create!({name: 'Adam', city: 'Santa Cruz'})
        User.create!({name: 'Jenna', city: 'Tempe'})
        User.create!({name: 'Marshall', city: 'San Francisco'})
      end
      it 'should be JSON API format and give 204 status' do
        get :index
        expect(response).to have_http_status(204)
        json = JSON.parse(response.body)
        expect(json['users']).to be_a(Array)
        expect(json['users'].length).to eq(3)
        expect(json['users'][0]['name']).to eq('Adam')
        expect(json['users'][0]['city']).to eq('Santa Cruz')
        expect(json['users'][1]['name']).to eq('Jenna')
        expect(json['users'][1]['city']).to eq('Tempe')
        expect(json['users'][2]['name']).to eq('Marshall')
        expect(json['users'][2]['city']).to eq('San Francisco')
      end
    end
  end
  describe 'POST #create' do
    context 'when given blank string' do
      it 'does nothing' do
        len1 = User.count
        post :create
        expect(response).to have_http_status(204)
        expect(User.count).to eq(len1)
      end
    end
    context 'when given json users hash not properly nested under users' do
      it 'does nothing' do
        len1 = User.count
        post :create, {name: 'Adam', city: 'Santa Cruz'}
        expect(response).to have_http_status(204)
        expect(User.count).to eq(len1)
      end
    end
    context 'when given a single user nested under users' do
      it 'should create the user' do
        len1 = User.count
        post :create, {users: {name: 'Adam', city: 'Santa Cruz'}}
        expect(response).to have_http_status(201)
        expect(User.count).to eq(len1+1)
        user = User.last
        expect(user.name).to eq('Adam')
        expect(user.city).to eq('Santa Cruz')
      end
    end
    context 'when given a multiple user nested under users' do
      it 'should create all of the users' do
        len1 = User.count
        user_params = {users: [
          {name: 'Adam', city: 'Santa Cruz'},
          {name: 'Jenna', city: 'Tempe'},
          {name: 'Marshall', city: 'San Francisco'}
        ]}
        post :create, user_params
        
        # Check database
        expect(User.count).to eq(len1+3)
        user_params[:users].each do |p|
          u = User.find_by_name(p[:name])
          expect(u).to_not be_nil
          expect(u.name).to eq(p[:name])
          expect(u.city).to eq(p[:city])
        end
        
        # Check response
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['users']).to be_a(Array)
        expect(json['users'].length).to eq(3)
        expect(json['users'][0]['name']).to eq('Adam')
        expect(json['users'][0]['city']).to eq('Santa Cruz')
        expect(json['users'][1]['name']).to eq('Jenna')
        expect(json['users'][1]['city']).to eq('Tempe')
        expect(json['users'][2]['name']).to eq('Marshall')
        expect(json['users'][2]['city']).to eq('San Francisco')
      end
    end
  end
end
