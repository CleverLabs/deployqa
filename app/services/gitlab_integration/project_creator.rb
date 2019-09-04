# frozen_string_literal: true

module GitlabIntegration
  class ProjectCreator
    def initialize(controller_params, current_user)
      @project_params = build_project_params(controller_params)
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        project = Project.create!(project_params)
        create_project_user_role(project)
        create_gitlab_repositories_info(project)

        ReturnValue.new(object: project, status: project.errors.any? ? :error : :ok)
      end
    end

    private

    attr_reader :project_params, :current_user

    def load_gitlab_repositories
      GitlabIntegration::ClientWrapper.new(current_user.token).load_projects
    end

    def create_gitlab_repositories_info(project)
      GitlabRepositoriesInfo.create!(project: project, data: load_gitlab_repositories.map(&:to_h))
    end

    def create_project_user_role(project)
      ProjectUserRole.create!(project: project, user: current_user, role: ProjectUserRoleConstants::ADMIN)
    end

    def build_project_params(controller_params)
      meaningless_integration_id = SecureRandom.uuid
      controller_params.merge(integration_id: meaningless_integration_id)
    end
  end
end
