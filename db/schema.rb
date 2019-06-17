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

ActiveRecord::Schema.define(version: 2019_06_17_093202) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "build_action_logs", force: :cascade do |t|
    t.bigint "build_action_id", null: false
    t.text "message", null: false
    t.string "context", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["build_action_id"], name: "index_build_action_logs_on_build_action_id"
  end

  create_table "build_actions", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "project_instance_id", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_build_actions_on_author_id"
    t.index ["project_instance_id"], name: "index_build_actions_on_project_instance_id"
  end

  create_table "deployment_configurations", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "private_key"
    t.string "repo_path", null: false
    t.jsonb "env_variables", default: {}, null: false
    t.string "public_key"
    t.string "integration_id", null: false
    t.string "integration_type", null: false
    t.integer "status", null: false
    t.index ["integration_id", "integration_type"], name: "index_deployment_configurations_on_integrations", unique: true
    t.index ["project_id"], name: "index_deployment_configurations_on_project_id"
  end

  create_table "github_entities", force: :cascade do |t|
    t.jsonb "data", default: {}, null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_github_entities_on_owner_type_and_owner_id", unique: true
  end

  create_table "project_instances", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "deployment_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.jsonb "configurations", default: {}, null: false
    t.integer "pull_request_number"
    t.index ["project_id"], name: "index_project_instances_on_project_id"
  end

  create_table "project_user_roles", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_project_user_roles_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_user_roles_on_project_id"
    t.index ["user_id"], name: "index_project_user_roles_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_secret_token"
    t.string "integration_id", null: false
    t.string "integration_type", null: false
    t.index ["integration_id", "integration_type"], name: "index_projects_on_integration_id_and_integration_type", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_provider", null: false
    t.string "auth_uid", null: false
    t.string "full_name"
    t.string "token"
  end

  create_table "webhook_logs", force: :cascade do |t|
    t.jsonb "body", null: false
    t.string "event", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "build_action_logs", "build_actions"
  add_foreign_key "project_user_roles", "projects"
  add_foreign_key "project_user_roles", "users"
end
