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

      @git_client_wrapper.add_deployqa_bot_to_repo(repository, permission: :maintainer)
      @git_client_wrapper.add_webhook_to_repo(repository)
      @git_client_wrapper.change_deployqa_bot_permission(repository, permission: :developer)

      ReturnValue.ok(repository)
    end
  end
end
