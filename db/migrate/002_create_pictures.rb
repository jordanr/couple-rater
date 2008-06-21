class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.integer :fb_id
      t.integer :user_id
      t.boolean :with_men
      t.boolean :with_women

      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
