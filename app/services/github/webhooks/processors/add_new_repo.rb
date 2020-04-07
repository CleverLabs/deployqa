# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class AddNewRepo
        def initialize(body)
          @wrapped_body = Github::Events::Installation.new(payload: body)
          @project = ::ProjectDomain.by_integration(ProjectsConstants::Providers::GITHUB, @wrapped_body.installation_id)
        end

        def call
          @wrapped_body.added_repos.each do |repo_info|
            create_repository(repo_info)
          end
          ReturnValue.ok
        end

        private

        def create_repository(repo_info)
          repository = ::Repository.find_or_create_by(project_id: @project.id, integration_type: ProjectsConstants::Providers::GITHUB, integration_id: repo_info.id)
          repository.update!(
            path: repo_info.full_name,
            name: repo_info.name,
            status: RepositoryConstants::INSTALLED
          )

          GithubEntity.ensure_info_exists(repository, repo_info.raw_info)
        end
      end
    end
  end
end
