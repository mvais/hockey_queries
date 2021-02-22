# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_22_022036) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "schedules", force: :cascade do |t|
    t.string "game_id", null: false
    t.integer "season", null: false
    t.date "game_date", null: false
    t.string "visitor_team_name", null: false
    t.string "visitor_team_abrv", null: false
    t.integer "visitor_team_goals", default: 0, null: false
    t.string "home_team_name", null: false
    t.string "home_team_abrv", null: false
    t.integer "home_team_goals", default: 0, null: false
    t.string "game_ended_status", default: "REG"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
