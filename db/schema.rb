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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120229203554) do

  create_table "people", :force => true do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "ssn",        :limit => 64
  end

  create_table "person_dimension", :force => true do |t|
    t.string   "first_name",     :limit => 50
    t.string   "last_name",      :limit => 50
    t.string   "address",        :limit => 100
    t.string   "city",           :limit => 50
    t.string   "state",          :limit => 50
    t.string   "zip_code",       :limit => 20
    t.datetime "effective_date"
    t.datetime "end_date"
    t.boolean  "latest_version"
  end

  create_table "places", :force => true do |t|
    t.text   "address"
    t.string "city"
    t.string "state"
    t.string "country", :limit => 2
  end

  create_table "truncate_test", :force => true do |t|
    t.string "x", :limit => 4
  end

end
