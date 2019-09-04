# frozen_string_literal: true

module GitlabIntegration
  class RepositoryCreator
    def initialize(repository_params, current_user)
      @params = repository_params
      @current_user = current_user
    end

    def call
      repository = Repository.create(@params)
      return ReturnValue.error(object: repository, errors: repository.errors) if repository.errors.present?

      GitlabIntegration::ClientWrapper.new(@current_user.token).add_deployqa_bot_to_repo(repository, permission: :reporter)
      ReturnValue.ok(repository)
    end
  end
end
