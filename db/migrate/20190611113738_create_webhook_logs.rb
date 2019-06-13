class CreateWebhookLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :webhook_logs do |t|
      t.jsonb :body, null: false
      t.string :event, null: false

      t.timestamps null: false
    end
  end
end
