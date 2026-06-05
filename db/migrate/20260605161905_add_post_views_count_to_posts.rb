class AddPostViewsCountToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :post_views_count, :integer
  end
end
