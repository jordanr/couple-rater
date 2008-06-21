class EditCouples < ActiveRecord::Migration
  def self.up
    add_column :couples, :picture1_likes_picture2, :boolean
    add_column :couples, :picture2_likes_picture1, :boolean
    add_column :couples, :ratings_sum, :integer
    add_column :couples, :ratings_count, :integer
  end

  def self.down
    remove_column :couples, :picture1_likes_picture2
    remove_column :couples, :picture2_likes_picture1
    remove_column :couples, :ratings_sum
    remove_column :couples, :ratings_count
  end
end
