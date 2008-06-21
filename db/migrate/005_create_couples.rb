class CreateCouples < ActiveRecord::Migration
  def self.up
    create_table :couples do |t|
      t.integer :picture_id1
      t.integer :picture_id2

      t.timestamps
    end
  end

  def self.down
    drop_table :couples
  end
end
