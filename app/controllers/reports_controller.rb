class ReportsController < ApplicationController


  # GET city_report
  def show_activities_by_city
    
    city = params[:city]
    
    user_ids = User.where('city = ?', city).map(&:id)
    
    if user_ids.blank?
      render json: {activities: nil}, status: 204
      return
    end
    
    posts = Post.where('user_id in (?)', user_ids)
    comments = Comment.where('user_id in (?)', user_ids)
    
    activities = posts.map(&:as_json_api) + comments.map(&:as_json_api)
    
    activities.sort_by!{|x|x[:updated_at]}
    
    render json: {activities: activities}, status: 204
    
    
    # full_outer_join(posts, comments).sort_by(:created_at).order(:asc)
    # map to [type, created_at, updated_at, title, content, message, links[users,posts]]
  
  end


end
