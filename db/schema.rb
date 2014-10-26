# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141010211854) do

  create_table "divisions", force: true do |t|
    t.string "name"
  end

  add_index "divisions", ["name"], name: "name_idx", unique: true, using: :btree

  create_table "ownerships", force: true do |t|
    t.integer  "team_id"
    t.integer  "player_id"
    t.integer  "round"
    t.integer  "pick"
    t.datetime "picked_at"
  end

  add_index "ownerships", ["player_id", "team_id"], name: "pt_idx", unique: true, using: :btree

  create_table "players", force: true do |t|
    t.string  "name"
    t.integer "position_id"
  end

  add_index "players", ["name", "position_id"], name: "np_idx", unique: true, using: :btree
  add_index "players", ["position_id"], name: "position_id_idx", using: :btree

  create_table "positions", force: true do |t|
    t.string "name"
  end

  add_index "positions", ["name"], name: "name_idx", unique: true, using: :btree

  create_table "site_configs", force: true do |t|
    t.string   "name"
    t.boolean  "as_boolean"
    t.integer  "as_integer"
    t.string   "as_string"
    t.datetime "as_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string  "name"
    t.integer "division_id"
  end

  add_index "teams", ["division_id"], name: "division_id idx", using: :btree
  add_index "teams", ["name", "division_id"], name: "nd_idx", unique: true, using: :btree
  add_index "teams", ["name"], name: "name_idx", unique: true, using: :btree

end
