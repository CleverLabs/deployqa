# frozen_string_literal: true

module Deployment
  class PullRequestNotificator
    PROVIDER_NOTIFICATOR = {
      ProjectsConstants::Providers::GITHUB => Github::PullRequestNotificator,
      ProjectsConstants::Providers::GITLAB => GitlabIntegration::MergeRequestNotificator
    }.freeze

    def initialize(project_instance)
      @project_instance = project_instance
      @project = project_instance.project
    end

    def call(text)
      notificator_class = PROVIDER_NOTIFICATOR.fetch(@project.integration_type)
      notificator_class.new(@project_instance).call(text)
    end
  end
end
