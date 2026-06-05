class FeedController < ApplicationController
  before_action :set_post, only: [ :edit, :update, :destroy ]
  before_action :authorize_post_owner!, only: [ :edit, :update, :destroy ]

  def index
    @pinned_posts = Post.feed_for(Current.user).pinned_first.where(pinned: true).limit(5)
    @posts = Post.feed_for(Current.user).not_pinned.page(params[:page]).per(10)
  end

  def show
    @post = Post.feed_for(Current.user).find(params[:id])
    @comments = @post.comments.includes(:user)
  end

  def mark_read
    @post = Post.feed_for(Current.user).find(params[:id])
    @post.post_views.find_or_create_by!(user: Current.user) unless @post.author == Current.user

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "read_status_#{ActionView::RecordIdentifier.dom_id(@post)}",
          partial: "feed/read_button",
          locals: { post: @post }
        )
      end
      format.html { redirect_to feed_index_path }
    end
  end

  def create
    unless Current.user.teacher? || Current.user.admin?
      redirect_to feed_index_path, alert: t("flash.feed.only_teachers_admins")
      return
    end

    scope_type, scope_id = params[:post][:scope].split("-")
    if scope_type == "General"
      scope_type = nil
      scope_id = nil
    end

    @post = Current.user.authored_posts.build(
      content: post_params[:content],
      scope_type: scope_type,
      scope_id: scope_id,
      pinned: post_params[:pinned] == "1",
      comments_disabled: post_params[:comments_disabled] == "1",
      attachments: post_params[:attachments]
    )

    if @post.save
      redirect_to feed_index_path, notice: t("flash.feed.post_created")
    else
      redirect_to feed_index_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    scope_type, scope_id = params[:post][:scope].split("-")
    if scope_type == "General"
      scope_type = nil
      scope_id = nil
    end

    @post.assign_attributes(
      content: params[:post][:content],
      scope_type: scope_type,
      scope_id: scope_id,
      pinned: params[:post][:pinned] == "1",
      comments_disabled: params.dig(:post, :comments_disabled) == "1"
    )

    if params[:post][:attachments].present?
      @post.attachments.attach(params[:post][:attachments])
    end

    if params[:remove_attachments].present?
      params[:remove_attachments].each do |attachment_id|
        @post.attachments_attachments.find_by(id: attachment_id)&.purge
      end
    end

    if @post.save
      redirect_to feed_index_path, notice: t("flash.feed.post_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.discard
    redirect_to feed_index_path, notice: t("flash.feed.post_deleted")
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_owner!
    unless @post.author == Current.user || Current.user.admin?
      redirect_to feed_index_path, alert: t("alerts.not_authorized")
    end
  end

  def post_params
    params.expect(post: [ :content, :pinned, :comments_disabled, { attachments: [] } ])
  end
end
