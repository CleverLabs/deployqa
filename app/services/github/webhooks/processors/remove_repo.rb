# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class RemoveRepo
        def initialize(body)
          @wrapped_body = Github::Events::Installation.new(payload: body)
          @project = ::ProjectDomain.by_integration(ProjectsConstants::Providers::GITHUB, @wrapped_body.installation_id)
        end

        def call
          repos_ids = @wrapped_body.removed_repos.map(&:id)
          ::Repository
            .where(project_id: @project.id, integration_type: ProjectsConstants::Providers::GITHUB, integration_id: repos_ids)
            .update_all(status: RepositoryConstants::REMOVED)
          ReturnValue.ok
        end
      end
    end
  end
end
