class EditUsers3 < ActiveRecord::Migration
  def self.up
      add_column :users, :network_id, :integer
  end

  def self.down
      remove_column :users, :network_id
  end
end
