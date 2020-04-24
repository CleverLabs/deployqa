class CreateBuildActionQueue < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      create_table :build_action_queues do |t|
        t.bigint :project_instance_id, null: false
        t.bigint :build_action_id, null: false
        t.jsonb :job_args, null: false

        t.timestamps null: false

        t.index :project_instance_id
      end

      add_foreign_key :build_action_queues, :project_instances, column: :project_instance_id
      add_foreign_key :build_action_queues, :build_actions, column: :build_action_id
    end
  end
end
