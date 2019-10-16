# frozen_string_literal: true

module GitlabIntegration
  class ProjectPage
    def initialize(current_user)
      @current_user = current_user
      @gitlab_client = ::ProviderAPI::Gitlab::UserClient.new(@current_user.token)
    end

    def build_project_names
      @gitlab_client.load_repositories.map { |repo| [repo.namespace.name, repo.namespace.id] }.uniq
    end

    def namespace_by_id(integration_id)
      @gitlab_client.load_repositories.map(&:namespace).find { |namespace| namespace.id == integration_id.to_i }
    end
  end
end
