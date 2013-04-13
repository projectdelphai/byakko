class User < ActiveRecord::Base
  has_secure_password
  
  attr_accessible :username, :password, :password_confirmation

  validates :password, presence: true, length: { within: 5..30 }
  validates :password_confirmation, presence: true
  validates :username, presence: true, length: { within: 5..30 }, uniqueness: true
end
