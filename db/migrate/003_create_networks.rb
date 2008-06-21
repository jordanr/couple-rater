class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.integer :fb_id
      t.string  :network

      t.timestamps
    end
  end

  def self.down
    drop_table :networks
  end
end
