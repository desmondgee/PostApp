require 'User'
class UsersController < ApplicationController

  def index
    users = User.all
    render json: {users: users}, status: 204
  end

  # POST /users
  def create
    if params[:users].nil?
      render nothing: true, status: 204
    elsif params[:users].is_a?(Array)
      User.transaction do
        results = []
        params[:users].each do |user_params|
          user_params = enforce_user_params(user_params)
          results << User.create!(user_params)
        end
        render json: {users:results}, status: 201
      end
    else
      user_params = enforce_user_params(params.require(:users))
      user = User.create!(user_params)
      render json: {users:user}, status: 201
    end
  end
  
  private 
    def enforce_user_params(params)
      user_params = params.permit(:name, :city)
      return user_params
    end
  
end
