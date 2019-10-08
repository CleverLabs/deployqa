# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    module Processors
      class CloseMergeRequest
        def initialize(body)
          @merge_request = GitlabIntegration::Wrappers::MergeRequest.new(body)
        end

        def call
          ReturnValue.ok unless repository.active?

          project_instance = repository.project.project_instances.find_by(attached_pull_request_number: @merge_request.number)
          Deployment::Processes::DestroyProjectInstance.new(project_instance, get_user(@merge_request.author_id)).call if project_instance
          ReturnValue.ok
        end

        private

        def get_user(user_id)
          ::User.find_or_create_by!(auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: user_id) do |user|
            user.full_name = @merge_request.user_name
          end
        end

        def repository
          @_repository ||= Repository.find_by(integration_id: @merge_request.repo_id, integration_type: ProjectsConstants::Providers::GITLAB)
        end
      end
    end
  end
end
