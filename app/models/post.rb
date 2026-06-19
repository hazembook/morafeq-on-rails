class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :scope, polymorphic: true, optional: true
  has_many_attached :attachments, dependent: :purge_later
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy, inverse_of: :post
  has_many :post_views, dependent: :destroy, inverse_of: :post

  validates :content, presence: true
  validates :scope_type, inclusion: { in: %w[College Department Subject] }, allow_nil: true
  validate :attachments_type_valid, if: -> { attachments.any? }
  validate :attachments_size_valid, if: -> { attachments.any? }

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }
  scope :not_pinned, -> { where(pinned: false) }

  after_create_commit :broadcast_create
  after_create_commit :notify_recipients
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy_callback

  def self.feed_for(user)
    return order(pinned: :desc, created_at: :desc) if user.admin?

    subject_ids = user.enrollments.select(:subject_id)
    subject_ids = user.taught_subjects.select(:id).or(Subject.where(id: subject_ids)) if user.teacher?

    department_ids = Subject.where(id: subject_ids).select(:department_id)
    college_ids = Department.where(id: department_ids).select(:college_id)

    where(
      "scope_type IS NULL OR " \
      "(scope_type = 'Subject' AND scope_id IN (?)) OR " \
      "(scope_type = 'Department' AND scope_id IN (?)) OR " \
      "(scope_type = 'College' AND scope_id IN (?))",
      subject_ids, department_ids, college_ids
    ).merge(pinned_first)
  end

  ALLOWED_ATTACHMENT_TYPES = (ALLOWED_IMAGE_TYPES + ALLOWED_DOCUMENT_TYPES + ALLOWED_MEDIA_TYPES).freeze

  MAX_FILE_SIZE = 50.megabytes

  private

  def attachments_type_valid
    attachments.each do |attachment|
      unless ALLOWED_ATTACHMENT_TYPES.include?(attachment.content_type)
        errors.add(:attachments, "must be an image, document, video, or audio file")
        break
      end
    end
  end

  def attachments_size_valid
    attachments.each do |attachment|
      if attachment.byte_size > MAX_FILE_SIZE
        errors.add(:attachments, "must be less than 50MB each")
      end
    end
  end

  def notify_recipients
    action = pinned? ? "new_pinned_post" : "new_post"
    NotificationJob.perform_later(author, action, self)
  end

  def broadcast_create
    target_stream = case scope_type
    when "Subject" then "posts_subject_#{scope_id}"
    when "Department" then "posts_department_#{scope_id}"
    when "College" then "posts_college_#{scope_id}"
    else "posts_general"
    end

    broadcast_prepend_to target_stream, target: "posts", partial: "feed/post", locals: { post: self }
  end

  def broadcast_update
    target_stream = case scope_type
    when "Subject" then "posts_subject_#{scope_id}"
    when "Department" then "posts_department_#{scope_id}"
    when "College" then "posts_college_#{scope_id}"
    else "posts_general"
    end

    broadcast_replace_to target_stream, target: "post_#{id}", partial: "feed/post", locals: { post: self }
  end

  def broadcast_destroy_callback
    streams = [ "posts_general" ]
    streams << "posts_subject_#{scope_id}" if scope_type == "Subject"
    streams << "posts_department_#{scope_id}" if scope_type == "Department"
    streams << "posts_college_#{scope_id}" if scope_type == "College"

    streams.each do |stream|
      broadcast_remove_to stream, target: "post_#{id}"
    end
  end
end
