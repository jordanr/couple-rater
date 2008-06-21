class EditUsers2 < ActiveRecord::Migration
  def self.up
      remove_column :users, :full_name
      add_column :users, :first_name, :string
      add_column :users, :last_name, :string
  end

  def self.down
      remove_column :users, :first_name
      remove_column :users, :last_name
      add_column :users, :full_name, :string
  end
end
