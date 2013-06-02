class Manga < ActiveRecord::Base
  attr_accessible :author, :chapters, :cover, :title

  validates :title, presence: true
  validates :author, presence: true

  def json_chapter_urls
    self.chapter_urls = YAML.load(self.chapter_urls)
  end
end
