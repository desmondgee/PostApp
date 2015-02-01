class User < ActiveRecord::Base
  has_many :posts
  has_many :comments, :through => :posts

  validates :name, presence: true, uniqueness: true
  validates :city, presence: true
end
