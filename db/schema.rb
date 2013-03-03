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

ActiveRecord::Schema.define(version: 20130302234758) do

  create_table "articles", force: true do |t|
    t.integer  "author_id"
    t.integer  "section_id"
    t.integer  "issue_id"
    t.string   "title"
    t.text     "abstract"
    t.text     "abstract_html"
    t.text     "abstract_english"
    t.text     "abstract_english_html"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.integer  "post_id"
    t.string   "email"
    t.text     "notes"
    t.integer  "institution_id"
    t.string   "phone"
    t.string   "title"
    t.string   "education"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "copies", force: true do |t|
    t.string   "page_code"
    t.text     "copy"
    t.text     "copy_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inquiries", force: true do |t|
    t.string   "name"
    t.string   "institution"
    t.string   "email"
    t.string   "phone"
    t.boolean  "show"
    t.string   "subject"
    t.text     "question"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "intitutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.integer  "year"
    t.integer  "issue"
    t.date     "published_at"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "orders", force: true do |t|
    t.string   "title"
    t.string   "name"
    t.string   "address"
    t.integer  "post_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "vat_id"
    t.string   "place_and_date"
    t.text     "comments"
    t.integer  "quantity"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
