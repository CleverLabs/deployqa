# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class UpdatePullRequest
        def initialize(body)
          @wrapped_body = Github::Events::PullRequest.new(payload: body)
          @project = ::ProjectDomain.by_integration(ProjectsConstants::Providers::GITHUB, @wrapped_body.installation_id)
        end

        def call
          return ReturnValue.ok unless @project.active_repository?(@wrapped_body.full_repo_name)

          project_instance = @project.project_instance(attached_pull_request_number: @wrapped_body.number)
          Deployment::Processes::UpdateProjectInstance.new(project_instance, user_reference(@wrapped_body.sender)).call if project_instance.present?
          ReturnValue.ok
        end

        private

        def user_reference(sender)
          ::UserReference.find_or_create_by!(auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: sender.id) do |user_reference|
            user_reference.full_name = sender.login
          end
        end
      end
    end
  end
end
