class User < ApplicationRecord
  has_secure_password
  has_many :recipients, dependent: :destroy

  before_save { self.email = email.downcase }
  before_create :confirm_session_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  def password_required?
    password_digest.blank? || password.present?
  end

  def reset_session_token!
    new_token = create_session_token
    update_columns(session_token: new_token, updated_at: Time.current)
    new_token
  end

  private
  def confirm_session_token
    self.session_token ||= create_session_token
  end
  def create_session_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(session_token: token)
    end
  end
end
