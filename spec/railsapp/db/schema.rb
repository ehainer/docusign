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

ActiveRecord::Schema.define(version: 20170720154843) do

  create_table "docusign_envelopes", force: :cascade do |t|
    t.string "envelope_id"
    t.integer "template_id"
    t.string "email_subject"
    t.text "email_blurb"
    t.integer "status", default: 0
    t.string "documents"
    t.string "envelopable_type"
    t.integer "envelopable_id"
    t.index ["envelopable_type", "envelopable_id"], name: "index_docusign_envelopes_on_envelopable_type_and_id"
    t.index ["envelope_id"], name: "index_docusign_envelopes_on_envelope_id", unique: true
  end

  create_table "docusign_signers", force: :cascade do |t|
    t.boolean "embedded", default: true
    t.string "name"
    t.string "email"
    t.string "role_name", default: "Issuer"
    t.string "recipient_id"
    t.integer "routing_order"
    t.text "tabs"
    t.string "signable_type"
    t.integer "signable_id"
    t.index ["signable_type", "signable_id"], name: "index_docusign_signers_on_signable_type_and_signable_id"
  end

  create_table "docusign_templates", force: :cascade do |t|
    t.string "template_id"
    t.string "email_subject"
    t.string "description"
    t.string "name"
    t.text "email_blurb"
    t.string "documents"
    t.string "templatable_type"
    t.integer "templatable_id"
    t.index ["templatable_type", "templatable_id"], name: "index_docusign_templates_on_templatable_type_and_id"
    t.index ["template_id"], name: "index_docusign_templates_on_template_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
