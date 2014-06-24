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

ActiveRecord::Schema.define(version: 20140619231402) do

  create_table "nodes", force: true do |t|
    t.integer  "tree_id"
    t.integer  "relative_id"
    t.string   "part_of_speech", limit: 10
    t.string   "contents",       limit: 140
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "x"
    t.integer  "y"
    t.integer  "pid"
    t.string   "type"
    t.integer  "trace_id"
    t.string   "trace_idx",      limit: 3
  end

  add_index "nodes", ["tree_id"], name: "index_nodes_on_tree_id"

  create_table "trees", force: true do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
