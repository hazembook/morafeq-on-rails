class FeedController < ApplicationController
  def index
    @pinned_posts = Post.feed_for(Current.user).pinned_first.where(pinned: true).limit(5)
    @posts = Post.feed_for(Current.user).not_pinned.page(params[:page]).per(10)
  end

  def create
    unless Current.user.teacher? || Current.user.admin?
      redirect_to feed_index_path, alert: "Only teachers and admins can create posts."
      return
    end

    scope_type, scope_id = params[:post][:scope].split("-")

    @post = Current.user.authored_posts.build(
      content: params[:post][:content],
      scope_type: scope_type,
      scope_id: scope_id,
      pinned: params[:post][:pinned] == "1"
    )

    if @post.save
      redirect_to feed_index_path, notice: "Post created."
    else
      redirect_to feed_index_path, alert: @post.errors.full_messages.to_sentence
    end
  end
end
