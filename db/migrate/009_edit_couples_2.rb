class EditCouples2 < ActiveRecord::Migration
  def self.up
    add_column :couples, :picture1_secretly_likes_picture2, :boolean
    add_column :couples, :picture2_secretly_likes_picture1, :boolean
  end

  def self.down
    remove_column :couples, :picture1_secretly_likes_picture2
    remove_column :couples, :picture2_secretly_likes_picture1
  end
end
