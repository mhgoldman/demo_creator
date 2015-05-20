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

ActiveRecord::Schema.define(version: 20150520105427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "demos", force: :cascade do |t|
    t.integer  "template_id"
    t.string   "description"
    t.integer  "requestor_id"
    t.integer  "status"
    t.string   "token"
    t.string   "published_url"
    t.datetime "confirmation_expiration"
    t.datetime "usage_expiration"
    t.integer  "skytap_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "provisioning_error"
  end

  create_table "que_jobs", primary_key: "queue", force: :cascade do |t|
    t.integer  "priority",    limit: 2, default: 100,                                        null: false
    t.datetime "run_at",                default: "now()",                                    null: false
    t.integer  "job_id",      limit: 8, default: "nextval('que_jobs_job_id_seq'::regclass)", null: false
    t.text     "job_class",                                                                  null: false
    t.json     "args",                  default: [],                                         null: false
    t.integer  "error_count",           default: 0,                                          null: false
    t.text     "last_error"
  end

  create_table "requestors", force: :cascade do |t|
    t.string   "email"
    t.string   "skytap_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.integer  "skytap_id"
    t.string   "name"
    t.string   "region_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
