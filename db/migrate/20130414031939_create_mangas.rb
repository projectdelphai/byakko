class CreateMangas < ActiveRecord::Migration
  def change
    create_table :mangas do |t|
      t.string :title
      t.string :author
      t.text :chapters
      t.string :cover

      t.timestamps
    end
  end
end
