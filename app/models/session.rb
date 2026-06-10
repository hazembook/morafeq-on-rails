class Session < ApplicationRecord
  DURATION = 30.days

  belongs_to :user, inverse_of: :sessions

  before_create :generate_token
  before_create :set_expiry

  scope :active, -> { where(expires_at: Time.current..) }

  def expired?
    expires_at < Time.current
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end

  def set_expiry
    self.expires_at ||= self.class::DURATION.from_now
    self.last_used_at ||= Time.current
  end
end
