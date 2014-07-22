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

ActiveRecord::Schema.define(version: 20140722174335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "executions", force: true do |t|
    t.string   "case"
    t.string   "scenario"
    t.integer  "line"
    t.string   "location"
    t.string   "result"
    t.string   "keyword"
    t.decimal  "duration"
    t.text     "exception"
    t.text     "log"
    t.integer  "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "start_time"
    t.string   "end_time"
    t.string   "tlib_version"
    t.string   "selenium_version"
    t.string   "python_version"
    t.string   "os"
    t.string   "processor"
    t.string   "machine"
    t.string   "ip"
    t.string   "browser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
