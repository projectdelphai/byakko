class Manga < ActiveRecord::Base
  attr_accessible :author, :chapters, :cover, :title

  validates :title, presence: true
  validates :author, presence: true
end
