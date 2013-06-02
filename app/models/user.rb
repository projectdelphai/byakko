class User < ActiveRecord::Base
  has_secure_password
  
  attr_accessible :username, :password, :password_confirmation, :subscription, :api_key

  before_save :create_remember_token

  validates :password, presence: true, length: { within: 5..30 }
  validates :password_confirmation, presence: true
  validates :username, presence: true, length: { within: 5..30 }, uniqueness: true

  def json_subscription
    self.subscription = YAML.load(self.subscription)
  end

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end


end
