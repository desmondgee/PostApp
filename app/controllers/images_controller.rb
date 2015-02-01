class ImagesController < ApplicationController

  # POST images
  def create
    if params[:images].present?
      image_params = params.require(:images).permit(:src, links: [:posts])
      image_params[:post_id] = (image_params[:links].present? ? image_params[:links][:posts] : nil)
      image_params.delete(:links)
      
      image = Image.create(image_params)
      if image.id.present?
        render json: {images: image.as_json_api}, status: 201
      else
        render nothing: true, status: 404
      end
    else
      render nothing: true, status: 404
    end
  end
  
  # DELETE images/:id
  def delete
    id = params[:id].to_i
    
    image = Image.find_by_id(id)
    
    if image.present?
      image.destroy
      render nothing: true, status: 204
    else
      render nothing: true, status: 404
    end
  end

end
