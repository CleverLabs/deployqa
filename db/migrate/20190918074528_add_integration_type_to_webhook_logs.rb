class AddIntegrationTypeToWebhookLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :webhook_logs, :integration_type, :integer
  end
end
