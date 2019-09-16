class ChangeWebhookLogsIntegrationTypeNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :webhook_logs, :integration_type, false
  end
end
