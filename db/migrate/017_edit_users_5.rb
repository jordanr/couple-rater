class EditUsers5 < ActiveRecord::Migration
  def self.up
      add_column :users, :see_question_marks, :boolean
  end

  def self.down
      remove_column :users, :see_question_marks
  end
end
