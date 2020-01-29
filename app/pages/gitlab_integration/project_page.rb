# frozen_string_literal: true

module GitlabIntegration
  class ProjectPage
    def initialize(current_user)
      @current_user = current_user
      @gitlab_client = ::ProviderAPI::Gitlab::UserClient.new(current_user.token_for(::ProjectsConstants::Providers::GITLAB))
    end

    def build_project_names
      namespaces = @gitlab_client.load_repositories.map do |repo|
        next if created_projects_integration_ids.include?(repo.namespace.id.to_s)

        [repo.namespace.name, repo.namespace.id]
      end

      namespaces.compact.uniq
    end

    def namespace_by_id(integration_id)
      @gitlab_client.load_repositories.map(&:namespace).find { |namespace| namespace.id == integration_id.to_i }
    end

    private

    def created_projects_integration_ids
      @_created_projects_integration_ids ||= Project.where(integration_type: ::ProjectsConstants::Providers::GITLAB).pluck(:integration_id)
    end
  end
end
