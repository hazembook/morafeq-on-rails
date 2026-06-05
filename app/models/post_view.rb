class PostView < ApplicationRecord
  belongs_to :post, inverse_of: :post_views, counter_cache: true
  belongs_to :user, inverse_of: :post_views

  validates :user_id, uniqueness: { scope: :post_id }
end
