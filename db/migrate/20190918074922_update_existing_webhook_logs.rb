class UpdateExistingWebhookLogs < ActiveRecord::Migration[5.2]
  GITHUB = "github"
  WebhookLog = Class.new(ActiveRecord::Base)

  def up
    WebhookLog.find_each do |log|
      log.update(integration_type: GITHUB)
    end
  end

  def down
    WebhookLog.find_each do |log|
      log.update(integration_type: nil)
    end
  end
end
