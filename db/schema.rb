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

ActiveRecord::Schema.define(version: 20180510012325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.string "order"
    t.string "estado"
    t.string "string"
    t.string "sku"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_infos", force: :cascade do |t|
    t.integer "sku"
    t.string "product"
    t.integer "lote"
    t.integer "nro"
    t.integer "man"
    t.integer "nar"
    t.integer "fru"
    t.integer "fra"
    t.integer "dur"
    t.integer "ara"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "productinfos", force: :cascade do |t|
    t.integer "sku"
    t.string "product"
    t.integer "lote"
    t.integer "nro"
    t.integer "man"
    t.integer "nar"
    t.integer "fru"
    t.integer "fra"
    t.integer "dur"
    t.integer "ara"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
