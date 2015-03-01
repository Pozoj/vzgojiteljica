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

ActiveRecord::Schema.define(version: 20150301175935) do

  create_table "articles", force: :cascade do |t|
    t.integer  "section_id"
    t.integer  "issue_id"
    t.text     "title"
    t.text     "abstract"
    t.text     "abstract_html"
    t.text     "abstract_english"
    t.text     "abstract_english_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "keywords_string",       limit: 255
  end

  add_index "articles", ["issue_id"], name: "index_articles_on_issue_id"
  add_index "articles", ["section_id"], name: "index_articles_on_section_id"

  create_table "authors", force: :cascade do |t|
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.string   "address",        limit: 255
    t.integer  "post_id"
    t.string   "email",          limit: 255
    t.text     "notes"
    t.integer  "institution_id"
    t.string   "phone",          limit: 255
    t.string   "title",          limit: 255
    t.string   "education",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["institution_id"], name: "index_authors_on_institution_id"
  add_index "authors", ["post_id"], name: "index_authors_on_post_id"

  create_table "authorships", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "author_id"
    t.integer  "position",   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorships", ["article_id"], name: "index_authorships_on_article_id"
  add_index "authorships", ["author_id", "article_id"], name: "index_authorships_on_author_id_and_article_id", unique: true
  add_index "authorships", ["author_id"], name: "index_authorships_on_author_id"

  create_table "bank_statements", force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "processed_at"
    t.text     "raw_statement"
    t.text     "parsed_statement"
    t.string   "statement_file_name"
    t.string   "statement_content_type"
    t.integer  "statement_file_size"
    t.datetime "statement_updated_at"
  end

  create_table "batches", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.decimal  "price"
    t.integer  "issues_per_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "copies", force: :cascade do |t|
    t.string   "page_code",  limit: 255
    t.text     "copy"
    t.text     "copy_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255
  end

  add_index "copies", ["page_code"], name: "index_copies_on_page_code"

  create_table "entities", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "name",            limit: 255
    t.string   "address",         limit: 255
    t.integer  "post_id",         limit: 4
    t.string   "city",            limit: 255
    t.string   "phone",           limit: 255
    t.string   "email",           limit: 255
    t.string   "vat_id",          limit: 255
    t.boolean  "vat_exempt"
    t.string   "type",            limit: 255
    t.integer  "entity_id"
    t.integer  "subscription_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_number"
    t.boolean  "einvoice"
  end

  add_index "entities", ["customer_id"], name: "index_entities_on_customer_id"
  add_index "entities", ["einvoice"], name: "index_entities_on_einvoice"
  add_index "entities", ["entity_id"], name: "index_entities_on_entity_id"
  add_index "entities", ["post_id"], name: "index_entities_on_post_id"
  add_index "entities", ["subscription_id"], name: "index_entities_on_subscription_id"

  create_table "inquiries", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "institution", limit: 255
    t.string   "email",       limit: 255
    t.string   "phone",       limit: 255
    t.boolean  "show"
    t.string   "subject",     limit: 255
    t.text     "question"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institutions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "customer_id"
    t.date     "due_at"
    t.decimal  "tax_percent"
    t.integer  "reference_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "paid_at"
    t.text     "bank_data"
    t.string   "bank_reference"
    t.integer  "subtotal_cents",       default: 0,     null: false
    t.string   "subtotal_currency",    default: "EUR", null: false
    t.integer  "total_cents",          default: 0,     null: false
    t.string   "total_currency",       default: "EUR", null: false
    t.integer  "paid_amount_cents",    default: 0,     null: false
    t.string   "paid_amount_currency", default: "EUR", null: false
    t.integer  "tax_cents",            default: 0,     null: false
    t.string   "tax_currency",         default: "EUR", null: false
  end

  add_index "invoices", ["bank_reference"], name: "index_invoices_on_bank_reference", unique: true
  add_index "invoices", ["customer_id"], name: "index_invoices_on_customer_id"
  add_index "invoices", ["paid_at"], name: "index_invoices_on_paid_at"
  add_index "invoices", ["reference_number"], name: "index_invoices_on_reference_number"

  create_table "issues", force: :cascade do |t|
    t.integer  "year"
    t.integer  "issue"
    t.date     "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_file_name",       limit: 255
    t.string   "cover_content_type",    limit: 255
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "batch_id"
  end

  add_index "issues", ["batch_id"], name: "index_issues_on_batch_id"
  add_index "issues", ["issue"], name: "index_issues_on_issue"
  add_index "issues", ["year"], name: "index_issues_on_year"

  create_table "keywordables", force: :cascade do |t|
    t.integer  "keyword_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywordables", ["article_id", "keyword_id"], name: "index_keywordables_on_article_id_and_keyword_id", unique: true
  add_index "keywordables", ["article_id"], name: "index_keywordables_on_article_id"
  add_index "keywordables", ["keyword_id", "article_id"], name: "index_keywordables_on_keyword_id_and_article_id", unique: true
  add_index "keywordables", ["keyword_id"], name: "index_keywordables_on_keyword_id"

  create_table "keywords", force: :cascade do |t|
    t.string   "keyword",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywords", ["keyword"], name: "index_keywords_on_keyword", unique: true

  create_table "line_items", force: :cascade do |t|
    t.integer  "invoice_id"
    t.string   "entity_name",                           limit: 255
    t.string   "product",                               limit: 255
    t.integer  "quantity"
    t.string   "unit",                                  limit: 255
    t.decimal  "discount_percent"
    t.decimal  "tax_percent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "issue_id"
    t.integer  "subtotal_cents",                                    default: 0,     null: false
    t.string   "subtotal_currency",                                 default: "EUR", null: false
    t.integer  "total_cents",                                       default: 0,     null: false
    t.string   "total_currency",                                    default: "EUR", null: false
    t.integer  "price_per_item_cents",                              default: 0,     null: false
    t.string   "price_per_item_currency",                           default: "EUR", null: false
    t.integer  "price_per_item_with_discount_cents",                default: 0,     null: false
    t.string   "price_per_item_with_discount_currency",             default: "EUR", null: false
    t.integer  "tax_cents",                                         default: 0,     null: false
    t.string   "tax_currency",                                      default: "EUR", null: false
  end

  add_index "line_items", ["invoice_id"], name: "index_line_items_on_invoice_id"

  create_table "news", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body"
    t.text     "body_html"
    t.string   "author",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "name",           limit: 255
    t.string   "address",        limit: 255
    t.integer  "post_id"
    t.string   "phone",          limit: 255
    t.string   "fax",            limit: 255
    t.string   "email",          limit: 255
    t.string   "vat_id",         limit: 255
    t.string   "place_and_date", limit: 255
    t.text     "comments"
    t.integer  "quantity"
    t.string   "ip",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plan_type"
    t.boolean  "processed",                  default: false
  end

  create_table "plans", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "billing_frequency"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "quantity_unit",      limit: 255
    t.string   "quantity_unit_abbr", limit: 255
    t.integer  "price_cents",                    default: 0,     null: false
    t.string   "price_currency",                 default: "EUR", null: false
  end

  create_table "posts", id: false, force: :cascade do |t|
    t.integer  "id"
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "regional_master"
    t.integer  "regional_master_id"
  end

  add_index "posts", ["id"], name: "index_posts_on_id"
  add_index "posts", ["regional_master"], name: "index_posts_on_regional_master"
  add_index "posts", ["regional_master_id"], name: "index_posts_on_regional_master_id"

  create_table "remarks", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "remark"
    t.string   "remarkable_type", limit: 255
    t.integer  "remarkable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remarks", ["remarkable_id"], name: "index_remarks_on_remarkable_id"
  add_index "remarks", ["remarkable_type"], name: "index_remarks_on_remarkable_type"
  add_index "remarks", ["user_id"], name: "index_remarks_on_user_id"

  create_table "sections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statement_entries", force: :cascade do |t|
    t.string   "account_holder"
    t.string   "account_number"
    t.integer  "amount_cents",      default: 0,     null: false
    t.string   "amount_currency",   default: "EUR", null: false
    t.date     "date"
    t.string   "details"
    t.integer  "bank_statement_id"
    t.string   "reference"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "statement_entries", ["bank_statement_id"], name: "index_statement_entries_on_bank_statement_id"
  add_index "statement_entries", ["reference"], name: "index_statement_entries_on_reference", unique: true

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "subscriber_id"
    t.date     "start"
    t.date     "end"
    t.integer  "discount"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity"
  end

  add_index "subscriptions", ["end"], name: "index_subscriptions_on_end"
  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id"
  add_index "subscriptions", ["start"], name: "index_subscriptions_on_start"
  add_index "subscriptions", ["subscriber_id"], name: "index_subscriptions_on_subscriber_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["entity_id"], name: "index_users_on_entity_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
