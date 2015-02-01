class Image < ActiveRecord::Base
  belongs_to :post
  delegate :user, to: :post
  
  validates :post, presence: true
  validates :src, presence: true
  
  def as_json_api
    return {
      id: self.id,
      src: self.src,
      links: {
        posts: self.post_id
      }
    }
  end
end
