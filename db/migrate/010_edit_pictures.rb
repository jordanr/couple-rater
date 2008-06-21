class EditPictures < ActiveRecord::Migration
  def self.up
    remove_column :pictures, :with_men
    remove_column :pictures, :with_women
  end

  def self.down
    add_column :pictures, :with_men, :boolean
    add_column :pictures, :with_women, :boolean
  end
end
