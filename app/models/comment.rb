class Comment < ApplicationRecord
  belongs_to :post, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  validates :content, presence: true
end
