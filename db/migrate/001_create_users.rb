class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer:fb_id
      t.integer:picture_id
      t.string :gender

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
