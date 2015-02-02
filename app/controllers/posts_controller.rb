class PostsController < ApplicationController

  # GET /posts
  def index
    posts = Post.all
    render json: {posts: posts}, status: 204
  end
  
  # POST /posts
  def create
    
    if params[:posts].nil?
      render nothing: true, status: 204
    elsif params[:posts].is_a?(Array)
      success = true
      results = []
      Post.transaction(requires_new: true) do
        params[:posts].each do |p|
          post_params = enforce_post_params(p)
          post = Post.create(post_params)
          if post.id.nil?
            success = false
            raise ActiveRecord::Rollback
          else
            results << post.as_json_api
          end
        end
      end
      
      if success
        render json: {'posts'=>results}, status: 201, location: posts_path
      else
        render nothing: true, status: 404
      end
    else
      post_params = enforce_post_params(params.require(:posts))
      post = Post.create(post_params)
      
      if post.id.present?
        render json: {posts: post.as_json_api}, status: 201, location: show_posts_path(post.id)
      else
        render nothing: true, status: 404
      end
    end
    
  end
  
  # GET /list_posts(/:count)
  def list
    count = params[:count] || 20
    posts = Post.includes(:user,:images).last(count)
    posts = posts.map{|p| {
      id: p.id,
      title: p.title,
      content: p.content,
      author_name: p.user.name,
      author_city: p.user.city,
      image_urls: p.images.map {|i| i.src}
    }}
    
    render json: posts, status: 204
  end
  
  # GET /posts/:id/comments
  def show_comments
    id = params[:id]
    
    post = Post.includes(:comments).find_by_id(id.to_i)
    if post.nil?
      render nothing: true, status: 404
    else
      comments = post.comments.map{|c|c.as_json_api}
      render json: {comments: comments}, status: 204
    end
  end
  
  # GET posts/*ids
  def show
    ids = params[:ids].split(",")
  
    if (ids.length == 1)
      post = Post.find_by_id(ids[0].to_i)
      if post.nil?
        render nothing: true, status: 404  
      else
        render json: {posts: post.as_json_api}, status: 204
      end
    else
      success = true
      results = []
      
      ids.each do |id|
        post = Post.find_by_id(id.to_i)
        if post.present? and post.id.present?
          results << post.as_json_api
        else
          success = false
          break
        end
      end
      
      if !success or results.blank?
        render nothing: true, status: 404  
      else
        render json: {posts: results}, status: 204
      end  
    end
  end
  
  # PUT posts/*ids
  def update
    success = true
    if params[:posts].is_a?(Array)
      Post.transaction(requires_new: true) do
        params[:posts].each do |p|
          post_params = enforce_post_params(p)
          post = Post.find_by_id(post_params['id'].to_i)
          if post.nil? || !post.update_attributes(post_params)
            success = false
            raise ActiveRecord::Rollback
          end
        end
      end
    else
      post_params = enforce_post_params(params.require(:posts))
      post = Post.find_by_id(post_params['id'].to_i)
      if post.nil? || !post.update_attributes(post_params)
        success = false
      end
    end
    
    if success
      render nothing: true, status: 204
    else
      render nothing: true, status: 404
    end
  end
  
  # DELETE posts/*id
  def delete
    ids = params[:ids].split(",").map{|id| id.to_i}
    
    success = true
    
    # rollback all if even one fails
    Post.transaction(requires_new: true) do 
      ids.each do |id|
        post = Post.find_by_id(id)
        if post.nil? || !post.destroy
          success = false
          raise ActiveRecord::Rollback
        end
      end
    end
    
    if success
      render nothing: true, status: 204
    else
      render nothing: true, status: 404  
    end
    
  end
  
  private
    # :id is ignored when used in mass assignment so it is safe for use in create.
    def enforce_post_params(params)
      params = params.permit(:id, :title,:content,links: [:users,:comments,:images])
      if params[:links].present?
        if params[:links][:users].present?
          params[:user_id] = params[:links][:users]
        end
        if params[:links][:comments].present?
          params[:comment_ids] = params[:links][:comments]
        end
        if params[:links][:images].present?
          params[:image_ids] = params[:links][:images]
        end
      end
      params.delete(:links)
      return params
    end
    
end
