# frozen_string_literal: true

module Notifications
  class Comment
    FIRST_COMMENT_TEXT = %{
---
[Create QA instance](%<deploy_url>s)
[Create custom QA instance](%<custom_deploy_url>s)
[Configuration](%<project_instance_url>s)
}

    def initialize(project_instance)
      @project_instance = project_instance
    end

    def failure_header
      "Unexpected error in deployka"
    end

    def header
      format(
        FIRST_COMMENT_TEXT,
        deploy_url: deploy_url,
        custom_deploy_url: deploy_url(custom_deploy: true),
        project_instance_url: project_instance_url
      )
    end

    def deploying
      "Deploying..."
    end

    def deployed
      "Application url: #{@project_instance.configurations.first.application_url}"
    end

    def failed
      "Deployment failed. <#{project_instance_url}|Project instance>"
    end

    private

    def deploy_url(options = {})
      Rails.application.routes.url_helpers.project_project_instance_deploy_url(@project_instance.project_id, @project_instance.id, options)
    end

    def project_instance_url
      Rails.application.routes.url_helpers.project_project_instance_url(@project_instance.project_id, @project_instance.id)
    end
  end
end
