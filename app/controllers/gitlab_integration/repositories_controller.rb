# frozen_string_literal: true

module GitlabIntegration
  class RepositoriesController < ::ApplicationController
    def new
      project = find_project

      update_gitlab_repositories_info!(project)

      @page = GitlabIntegration::RepositoryPage.new(project)
      @repository = @page.project.repositories.build
    end

    def create
      @page = GitlabIntegration::RepositoryPage.new(find_project)
      result = GitlabIntegration::RepositoryCreator.new(create_repository_form.attributes, gitlab_client_wrapper).call

      if result.ok?
        redirect_to project_path(@page.project)
      else
        @repository = result.object
        @errors = result.errors
        render :new
      end
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
    end

    def create_repository_form
      gitlab_repository = @page.find_gitlab_repo_by_id(repository_params[:integration_id].to_i)

      RepositoryForm.new(repository_params.merge(project: @page.project,
                                                 name: gitlab_repository["name"],
                                                 path: gitlab_repository["path_with_namespace"],
                                                 integration_type: ProjectsConstants::Providers::GITLAB))
    end

    def update_gitlab_repositories_info!(project)
      gitlab_repos = ::ProviderApi::Gitlab::UserClient.new(current_user.token_for(::ProjectsConstants::Providers::GITLAB)).load_repositories
      # TODO: For now we don't remove repositories with their dependencies so it's ok for removed repos on Gitlab.
      # TODO: But in future a service usage may be here.
      project.gitlab_repositories_info.update!(data: gitlab_repos.map(&:to_h))
    end

    def repository_params
      params.require(:repository).permit(
        :integration_id, :runtime_env_variables, :build_env_variables, :build_type, :seeds_command, addon_ids: [], web_processes_attributes: %i[id name command]
      )
    end

    def gitlab_client_wrapper
      ::ProviderApi::Gitlab::UserClient.new(current_user.token_for(::ProjectsConstants::Providers::GITLAB))
    end
  end
end
