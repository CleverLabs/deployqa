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

ActiveRecord::Schema.define(version: 2020_03_31_200629) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addons", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integration_provider", null: false
    t.string "credentials_names", default: [], null: false, array: true
    t.integer "addon_type", null: false
    t.index ["name"], name: "index_addons_on_name", unique: true
  end

  create_table "auth_infos", force: :cascade do |t|
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token", null: false
    t.boolean "primary", default: false, null: false
    t.string "email", null: false
    t.bigint "user_reference_id", null: false
    t.index ["user_reference_id"], name: "index_auth_infos_on_user_reference_id", unique: true
  end

  create_table "build_action_logs", force: :cascade do |t|
    t.bigint "build_action_id", null: false
    t.text "message", null: false
    t.string "context", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_backtrace"
    t.index ["build_action_id"], name: "index_build_action_logs_on_build_action_id"
  end

  create_table "build_actions", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "project_instance_id", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "git_reference"
    t.jsonb "configurations", default: {}, null: false
    t.index ["author_id"], name: "index_build_actions_on_author_id"
    t.index ["project_instance_id"], name: "index_build_actions_on_project_instance_id"
  end

  create_table "email_whitelists", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_whitelists_on_email", unique: true
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "github_entities", force: :cascade do |t|
    t.jsonb "data", default: {}, null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_github_entities_on_owner_type_and_owner_id", unique: true
  end

  create_table "gitlab_repositories_infos", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_gitlab_repositories_infos_on_project_id"
  end

  create_table "project_addon_infos", force: :cascade do |t|
    t.jsonb "tokens", default: {}, null: false
    t.bigint "project_id", null: false
    t.bigint "addon_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addon_id"], name: "index_project_addon_infos_on_addon_id"
    t.index ["project_id", "addon_id"], name: "index_project_addon_infos_on_project_id_and_addon_id", unique: true
    t.index ["project_id"], name: "index_project_addon_infos_on_project_id"
  end

  create_table "project_instances", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "deployment_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.jsonb "configurations", default: {}, null: false
    t.integer "attached_pull_request_number"
    t.string "attached_repo_path"
    t.jsonb "branches", default: {}, null: false
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
    t.string "integration_id", null: false
    t.integer "integration_type", null: false
    t.string "private_key"
    t.string "public_key"
    t.index ["integration_id", "integration_type"], name: "index_projects_on_integration_id_and_integration_type", unique: true
  end

  create_table "repositories", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.integer "integration_type", null: false
    t.string "integration_id", null: false
    t.integer "status", null: false
    t.string "path", null: false
    t.jsonb "runtime_env_variables", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "build_type", default: 0, null: false
    t.jsonb "build_env_variables", default: {}, null: false
    t.string "heroku_buildpacks", default: [], null: false, array: true
    t.string "seeds_command"
    t.index ["integration_id", "integration_type"], name: "index_repositories_on_integration_id_and_integration_type", unique: true
    t.index ["project_id", "path"], name: "index_repositories_on_project_id_and_path", unique: true
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "repositories_addons", force: :cascade do |t|
    t.bigint "repository_id", null: false
    t.bigint "addon_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addon_id"], name: "index_repositories_addons_on_addon_id"
    t.index ["repository_id", "addon_id"], name: "index_repositories_addons_on_repository_id_and_addon_id", unique: true
    t.index ["repository_id"], name: "index_repositories_addons_on_repository_id"
  end

  create_table "slack_entities", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.jsonb "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_slack_entities_on_project_id", unique: true
  end

  create_table "user_references", force: :cascade do |t|
    t.bigint "user_id"
    t.string "full_name", null: false
    t.string "auth_uid", null: false
    t.integer "auth_provider", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_uid", "auth_provider"], name: "index_user_references_on_auth_uid_and_auth_provider", unique: true
    t.index ["user_id"], name: "index_user_references_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.integer "system_role", default: 0, null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "waiting_lists", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_waiting_lists_on_email", unique: true
  end

  create_table "web_processes", force: :cascade do |t|
    t.bigint "repository_id", null: false
    t.string "name", null: false
    t.string "command", null: false
    t.integer "number", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_web_processes_on_repository_id"
  end

  create_table "webhook_logs", force: :cascade do |t|
    t.jsonb "body", null: false
    t.string "event", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "integration_type", null: false
  end

  add_foreign_key "auth_infos", "user_references"
  add_foreign_key "build_action_logs", "build_actions"
  add_foreign_key "gitlab_repositories_infos", "projects"
  add_foreign_key "project_addon_infos", "addons"
  add_foreign_key "project_addon_infos", "projects"
  add_foreign_key "project_user_roles", "projects"
  add_foreign_key "project_user_roles", "users"
  add_foreign_key "repositories", "projects"
  add_foreign_key "repositories_addons", "addons"
  add_foreign_key "repositories_addons", "repositories"
  add_foreign_key "slack_entities", "projects"
  add_foreign_key "user_references", "users"
  add_foreign_key "web_processes", "repositories"
end
