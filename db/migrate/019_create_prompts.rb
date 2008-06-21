class CreatePrompts < ActiveRecord::Migration
  def self.up
    create_table :prompts do |t|
      t.string :text
      t.integer :user_id
      t.timestamps
    end

    Prompt.create :text=> "Would this be a good couple?"
    Prompt.create :text=> "Should these two hang out together?"
    Prompt.create :text=> "Two of a kind?"
    Prompt.create :text=> "Would these two get along with each other?"
    Prompt.create :text=> "How about this couple?"
    Prompt.create :text=> "What do you think of these two?"
  end

  def self.down
    drop_table :prompts
  end
end
