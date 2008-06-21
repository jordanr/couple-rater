class EditUsers6 < ActiveRecord::Migration
  def self.up
      remove_column :users, :network_id
      remove_column :users, :friends_can_search_for_me
      remove_column :users, :non_friends_can_search_for_me
  end

  def self.down
      add_column :users, :network_id, integer
      add_column :users, :friends_can_search_for_me, boolean
      add_column :users, :non_friends_can_search_for_me, boolean
  end
end
