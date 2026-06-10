ALLOWED_IMAGE_TYPES = %w[
  image/png image/jpeg image/gif image/webp
].freeze

ALLOWED_DOCUMENT_TYPES = %w[
  application/pdf
  application/vnd.ms-powerpoint
  application/vnd.openxmlformats-officedocument.presentationml.presentation
  application/msword
  application/vnd.openxmlformats-officedocument.wordprocessingml.document
].freeze

ALLOWED_MEDIA_TYPES = %w[
  video/mp4 video/webm
  audio/mpeg audio/ogg audio/wav
].freeze

ALLOWED_ATTACHMENT_TYPES = (ALLOWED_IMAGE_TYPES + ALLOWED_DOCUMENT_TYPES + ALLOWED_MEDIA_TYPES).freeze
