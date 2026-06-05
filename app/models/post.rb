class Post < ApplicationRecord
  include Discard::Model

  belongs_to :author, class_name: "User"
  belongs_to :scope, polymorphic: true, optional: true
  has_many_attached :attachments, dependent: :purge_later
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy, inverse_of: :post

  validates :content, presence: true
  validates :scope_type, inclusion: { in: %w[College Department Subject] }, allow_nil: true

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }
  scope :not_pinned, -> { where(pinned: false) }

  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy_callback

  def self.feed_for(user)
    return kept.order(pinned: :desc, created_at: :desc) if user.admin?

    subject_ids = user.enrollments.select(:subject_id)
    subject_ids = user.taught_subjects.select(:id).or(Subject.where(id: subject_ids)) if user.teacher?

    department_ids = Subject.where(id: subject_ids).select(:department_id)
    college_ids = Department.where(id: department_ids).select(:college_id)

    kept.where(
      "scope_type IS NULL OR " \
      "(scope_type = 'Subject' AND scope_id IN (?)) OR " \
      "(scope_type = 'Department' AND scope_id IN (?)) OR " \
      "(scope_type = 'College' AND scope_id IN (?))",
      subject_ids, department_ids, college_ids
    ).merge(pinned_first)
  end

  private

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
    if discarded?
      broadcast_destroy_callback
    else
      target_stream = case scope_type
      when "Subject" then "posts_subject_#{scope_id}"
      when "Department" then "posts_department_#{scope_id}"
      when "College" then "posts_college_#{scope_id}"
      else "posts_general"
      end

      broadcast_replace_to target_stream, target: "post_#{id}", partial: "feed/post", locals: { post: self }
    end
  end

  def broadcast_destroy_callback
    streams = ["posts_general"]
    streams << "posts_subject_#{scope_id}" if scope_type == "Subject"
    streams << "posts_department_#{scope_id}" if scope_type == "Department"
    streams << "posts_college_#{scope_id}" if scope_type == "College"

    streams.each do |stream|
      broadcast_remove_to stream, target: "post_#{id}"
    end
  end
end
