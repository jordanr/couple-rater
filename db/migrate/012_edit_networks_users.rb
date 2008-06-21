class EditNetworksUsers < ActiveRecord::Migration
  def self.up
    drop_table :networks_users
    create_table :networks_users, :id=> false do |t|
	t.integer :network_id
	t.integer :user_id
    end
  end

  def self.down
    drop_table :networks_users
    create_table :networks_users do |t|
        t.integer :network_id
        t.integer :user_id
    end
  end
end
