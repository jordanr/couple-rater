class CreateCouplesNetworks < ActiveRecord::Migration
  def self.up
    create_table :couples_networks, :id=> false do |t|
	t.integer :couple_id
	t.integer :network_id
    end
  end

  def self.down
    drop_table :couples_networks
  end
end
