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

ActiveRecord::Schema.define(version: 20130304042347) do

  create_table "articles", force: true do |t|
    t.integer  "section_id"
    t.integer  "issue_id"
    t.text     "title",                 limit: 255
    t.text     "abstract"
    t.text     "abstract_html"
    t.text     "abstract_english"
    t.text     "abstract_english_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "keywords_string"
  end

  add_index "articles", ["issue_id"], name: "index_articles_on_issue_id"
  add_index "articles", ["section_id"], name: "index_articles_on_section_id"

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

  add_index "authors", ["institution_id"], name: "index_authors_on_institution_id"
  add_index "authors", ["post_id"], name: "index_authors_on_post_id"

  create_table "authorships", force: true do |t|
    t.integer  "article_id"
    t.integer  "author_id"
    t.integer  "position",   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorships", ["article_id"], name: "index_authorships_on_article_id"
  add_index "authorships", ["author_id", "article_id"], name: "index_authorships_on_author_id_and_article_id", unique: true
  add_index "authorships", ["author_id"], name: "index_authorships_on_author_id"

  create_table "copies", force: true do |t|
    t.string   "page_code"
    t.text     "copy"
    t.text     "copy_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "copies", ["page_code"], name: "index_copies_on_page_code"

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

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.integer  "year"
    t.integer  "issue"
    t.date     "published_at"
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

  add_index "issues", ["issue"], name: "index_issues_on_issue"
  add_index "issues", ["year"], name: "index_issues_on_year"

  create_table "keywordables", force: true do |t|
    t.string   "keyword_id"
    t.string   "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywordables", ["article_id", "keyword_id"], name: "index_keywordables_on_article_id_and_keyword_id", unique: true
  add_index "keywordables", ["article_id"], name: "index_keywordables_on_article_id"
  add_index "keywordables", ["keyword_id", "article_id"], name: "index_keywordables_on_keyword_id_and_article_id", unique: true
  add_index "keywordables", ["keyword_id"], name: "index_keywordables_on_keyword_id"

  create_table "keywords", force: true do |t|
    t.string   "keyword"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywords", ["keyword"], name: "index_keywords_on_keyword", unique: true

  create_table "news", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.text     "body_html"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "posts", id: false, force: true do |t|
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["id"], name: "index_posts_on_id"

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
