# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 19) do

  create_table "couples", :force => true do |t|
    t.integer  "picture_id1"
    t.integer  "picture_id2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "picture1_likes_picture2"
    t.boolean  "picture2_likes_picture1"
    t.integer  "ratings_sum"
    t.integer  "ratings_count"
    t.boolean  "picture1_secretly_likes_picture2"
    t.boolean  "picture2_secretly_likes_picture1"
  end

  create_table "couples_networks", :id => false, :force => true do |t|
    t.integer "couple_id"
    t.integer "network_id"
  end

  create_table "networks", :force => true do |t|
    t.integer  "fb_id"
    t.string   "network"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks_users", :id => false, :force => true do |t|
    t.integer "network_id"
    t.integer "user_id"
  end

  create_table "pictures", :force => true do |t|
    t.integer  "fb_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prompts", :force => true do |t|
    t.string   "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "couple_id"
    t.integer  "rating"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.integer  "fb_id"
    t.integer  "picture_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "gender"
    t.boolean  "with_men"
    t.boolean  "with_women"
    t.boolean  "friends_can_see_my_matches"
    t.boolean  "non_friends_can_see_my_matches"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "session_key"
    t.boolean  "see_question_marks"
  end

end
