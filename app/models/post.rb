class Post < ActiveRecord::Base
  belongs_to :user  # :author, class_name: 'User'
  has_many :images, :dependent => :destroy
  has_many :comments, :dependent => :destroy  # destory all related comments
  
  validates :user, presence: true
  
  def as_json_api
    return {
      id: self.id,
      type: 'posts',
      title: self.title,
      content: self.content,
      updated_at: self.updated_at,
      created_at: self.created_at,
      links: {
        users: self.user_id,
        images: self.image_ids,
        comments: self.comment_ids
      }
    }
  end
end
