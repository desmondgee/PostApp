class Comment < ActiveRecord::Base
  belongs_to :post, touch: true
  belongs_to :user    # commentor
  belongs_to :comment # parent comment for nesting. nil if no parent comment. 
  has_many :comments, dependent: :destroy  # most immediate nested comments. destroying a comment destroys its thread.

  validates :post, presence: true
  validates :user, presence: true
  validate :comment_must_have_same_post_id_as_parent_comment_if_present
  
  def comment_must_have_same_post_id_as_parent_comment_if_present
    if self.comment.present?
      if self.comment.post_id != self.post_id
        errors.add(:comment, 'Can only reply to a comment in same post')
      end
    end
  end
  
  def as_json_api
    return {
      id: self.id,
      type: 'comments',
      message: self.message,
      created_at: self.created_at,
      updated_at: self.updated_at,
      links: {
        users: self.user_id,
        posts: self.post_id,
        comments: self.comment_id
      }
    }
  end
end
