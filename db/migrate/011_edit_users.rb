class EditUsers < ActiveRecord::Migration
  def self.up
      remove_column :users, :gender
      add_column :users, :full_name, :string
      add_column :users, :gender, :boolean
      add_column :users, :with_men, :boolean
      add_column :users, :with_women, :boolean
      add_column :users, :friends_can_see_my_matches, :boolean
      add_column :users, :non_friends_can_see_my_matches, :boolean
      add_column :users, :friends_can_search_for_me, :boolean
      add_column :users, :non_friends_can_search_for_me, :boolean
  end

  def self.down
      remove_column :users, :full_name
      remove_column :users, :gender
      remove_column :users, :with_men
      remove_column :users, :with_women
      remove_column :users, :friends_can_see_my_matches
      remove_column :users, :non_friends_can_see_my_matches
      remove_column :users, :friends_can_search_for_me
      remove_column :users, :non_friends_can_search_for_me
      add_column :users, :gender, :string
  end
end
