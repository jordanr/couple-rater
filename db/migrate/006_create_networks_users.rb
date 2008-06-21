class CreateNetworksUsers < ActiveRecord::Migration
  def self.up
    create_table :networks_users, :id=> false do |t|
	t.integer :network_id
	t.integer :user_id
    end
  end

  def self.down
    drop_table :networks_users
  end
end
