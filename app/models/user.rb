class User < ActiveRecord::Base
  has_secure_password
  
  attr_accessible :username, :password, :password_confirmation, :subscription, :api_key

  before_save :create_remember_token
  before_save :create_api_key

  validates :password, presence: true, length: { within: 5..30 }
  validates :password_confirmation, presence: true
  validates :username, presence: true, length: { within: 5..30 }, uniqueness: true

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  def create_api_key
    self.api_key = SecureRandom.hex
  end

end
