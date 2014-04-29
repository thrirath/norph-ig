class CreateInstagramTags < ActiveRecord::Migration
  def change
    create_table :instagram_tags do |t|
      t.string :tag
      t.text :media_id

      t.timestamps
    end
  end
end
