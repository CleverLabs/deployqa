# frozen_string_literal: true

module GitlabIntegration
  class ProjectCreator
    def initialize(controller_params, current_user)
      @project_params = controller_params
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        project = Project.create!(project_params)
        BillingDomain.create!(project: ProjectDomain.new(record: project))
        perform_plugins_callback(project)
        create_project_user_role(project)
        create_gitlab_repositories_info(project)

        ReturnValue.new(object: project, status: project.errors.any? ? :error : :ok)
      end
    end

    private

    attr_reader :project_params, :current_user

    def perform_plugins_callback(project)
      project_info = Plugins::Adapters::NewProject.build(project)
      Plugins::Entry::OnProjectCreation.new(project_info).call
    end

    def load_gitlab_repositories
      repositories = ::ProviderApi::Gitlab::UserClient.new(current_user.token_for(::ProjectsConstants::Providers::GITLAB)).load_repositories
      repositories.filter { |repository| repository.namespace.id == @project_params[:integration_id].to_i }
    end

    def create_gitlab_repositories_info(project)
      GitlabRepositoriesInfo.create!(project: project, data: load_gitlab_repositories.map(&:to_h))
    end

    def create_project_user_role(project)
      # current_user is the wrapper, therefore using direct ID to reference the user
      ProjectUserRole.create!(project: project, user_id: current_user.id, role: ProjectUserRoleConstants::ADMIN)
    end
  end
end
