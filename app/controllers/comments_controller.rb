class CommentsController < ApplicationController
  before_action :require_authentication

  def create
    @post = Post.feed_for(Current.user).find(params[:feed_id])
    authorize @post, :show?
    @comment = @post.comments.build(comment_params.merge(user: Current.user))

    if @comment.save
      redirect_to feed_path(@post), notice: t("flash.comments.created", default: "Comment added successfully!")
    else
      redirect_to feed_path(@post), alert: @comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
