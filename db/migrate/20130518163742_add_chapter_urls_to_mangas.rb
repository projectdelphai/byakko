class AddChapterUrlsToMangas < ActiveRecord::Migration
  def change
    add_column :mangas, :chapter_urls, :text
  end
end
