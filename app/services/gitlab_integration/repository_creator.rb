# frozen_string_literal: true

module GitlabIntegration
  class RepositoryCreator
    def initialize(repository_params, git_client_wrapper)
      @params = repository_params
      @git_client_wrapper = git_client_wrapper
    end

    def call
      repository = Repository.create(@params)
      return ReturnValue.error(object: repository, errors: repository.errors) if repository.errors.present?

      setup_gitlab_repository(repository)

      repository_settings = create_repository_settings(repository)

      if repository_settings.errors.empty?
        ReturnValue.ok(repository)
      else
        ReturnValue.error(object: repository, errors: repository_settings.errors)
      end
    end

    private

    def perform_creation_callback(repository)
      wrapped_repo = Plugins::Adapters::NewRepo.build(repository.project, repository.name)
      Plugins::Entry::OnRepoCreation.new(wrapped_repo).call
    end

    def setup_gitlab_repository(repository)
      @git_client_wrapper.add_deployqa_bot_to_repo(repository, permission: :maintainer)
      @git_client_wrapper.add_webhook_to_repo(repository)
      perform_creation_callback(repository)
    end

    def create_repository_settings(repository)
      deploy_token = @git_client_wrapper.gitlab_create_deploy_token(repository)
      RepositorySetting.create(repository_id: repository.id, data: { deploy_token: deploy_token.to_h })
    end
  end
end
