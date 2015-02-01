class CommentsController < ApplicationController


  # GET /comments
  def index
    comments = Comment.all
    render json: {comments: comments}, status: 204
  end
  
  # POST /comments
  def create
    
    if params[:comments].nil?
      render nothing: true, status: 204
    elsif params[:comments].is_a?(Array)
      success = true
      results = []
      post_ids = {} 
      Comment.transaction(requires_new: true) do
        params[:comments].each do |p|
          comment_params = enforce_comment_params(p)
          comment = Comment.create(comment_params)
          if comment.id.nil?
            success = false
            raise ActiveRecord::Rollback
          else
            post_ids[comment.post_id] = true
            results << comment.as_json_api
          end
        end
      end
      
      if success
        #Post.where({id: post_ids.keys}).update_all({updated_at: Time.now})
        render json: {'comments'=>results}, status: 201, location: comments_path
      else
        render nothing: true, status: 404
      end
      
    else
      comment_params = enforce_comment_params(params.require(:comments))
      comment = Comment.create(comment_params)
      if comment.id.present?
        #comment.post.touch
        render json: {comments: comment.as_json_api}, status: 201, location: show_comments_path(comment.id)
      else
        render nothing: true, status: 404
      end
      
    end
    
  end
  
  # GET comments/*ids
  def show
    ids = params[:ids].split(",")
  
    if (ids.length == 1)
      comment = Comment.find_by_id(ids[0].to_i)
      if comment.nil?
        render nothing: true, status: 404  
      else
        render json: {comments: comment.as_json_api}, status: 204
      end
    else
      success = true
      results = []
      ids.each do |id|
        comment = Comment.find_by_id(id.to_i)
        if comment.present?
          results << comment.as_json_api
        else
          success = false
          break
        end
      end
      if !success or results.blank?
        render nothing: true, status: 404  
      else
        render json: {comments: results}, status: 204
      end  
    end
  end
  
  # PUT comments/*ids
  def update
    success = true
    if params[:comments].is_a?(Array)
      Comment.transaction(requires_new: true) do
        params[:comments].each do |p|
          comment_params = enforce_comment_params(p)
          comment = Comment.find_by_id(comment_params['id'].to_i)
          if comment.nil? || !comment.update_attributes(comment_params)
            success = false
            raise ActiveRecord::Rollback
          end
        end
      end
    else
      comment_params = enforce_comment_params(params.require(:comments))
      comment = Comment.find_by_id(comment_params['id'].to_i)
      if comment.nil? || !comment.update_attributes(comment_params)
        success = false
      end
    end
    
    if success
      render nothing: true, status: 204
    else
      render nothing: true, status: 404
    end
  end
  
  # DELETE comments/*id
  def delete
    ids = params[:ids].split(",").map{|id| id.to_i}
    
    success = true
    
    # rollback all if even one fails
    Comment.transaction(requires_new: true) do 
      ids.each do |id|
        comment = Comment.find_by_id(id)
        if comment.nil? || !comment.destroy
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
    def enforce_comment_params(params)
      params = params.permit(:id, :message, links: [:users,:posts])
      if params[:links].present?
        if params[:links][:users].present?
          params[:user_id] = params[:links][:users]
        end
        if params[:links][:posts].present?
          params[:post_id] = params[:links][:posts]
        end
      end
      params.delete(:links)
      return params
    end
    
    
end
