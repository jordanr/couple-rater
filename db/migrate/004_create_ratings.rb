class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :couple_id
      t.integer :rating
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
