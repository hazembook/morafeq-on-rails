class MagicBytesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    attachments = value.respond_to?(:each) ? value : [ value ].compact

    attachments.each do |attachment|
      next unless attachment.respond_to?(:attached?) ? attachment.attached? : true

      detected = detect_mime_type(attachment)

      allowed = options[:allowed]
      next if allowed.include?(detected)

      record.errors.add(attribute, :invalid_magic_bytes, detected: detected)
    end
  end

  private

  def detect_mime_type(attachment)
    blob = attachment.blob
    if blob.persisted?
      blob.open { |f| Marcel::MimeType.for(f) }
    else
      blob.content_type
    end
  rescue ActiveStorage::FileNotFoundError
    blob.content_type
  end
end
