# frozen_string_literal: true

module GitProviders
  module Url
    class PullMergeRequest
      PULL_REQUEST_URLS = {
        ProjectsConstants::Providers::GITHUB => ->(repo_path, attached_pr_number) { ::Github::Router.new.pull_request_url(repo_path, attached_pr_number) },
        ProjectsConstants::Providers::GITLAB => ->(repo_path, attached_pr_number) { ::GitlabIntegration::Router.new.merge_request_url(repo_path, attached_pr_number) }
      }.freeze

      def initialize(project_instance, integration_type)
        @project_instance = project_instance
        @integration_type = integration_type
      end

      def call
        return unless @project_instance.attached_pull_request_number
        return unless PULL_REQUEST_URLS.key?(@integration_type)

        PULL_REQUEST_URLS.fetch(@integration_type).call(@project_instance.attached_repo_path, @project_instance.attached_pull_request_number)
      end
    end
  end
end
