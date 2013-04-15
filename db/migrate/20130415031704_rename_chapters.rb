class RenameChapters < ActiveRecord::Migration
  def change
    rename_column :mangas, :chapters, :latestchapter
  end
end
