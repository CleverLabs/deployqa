# frozen_string_literal: true

module GitlabIntegration
  class RepositoryPage
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def build_repository
      project.repositories.build
    end

    def gitlab_repositories_collection
      collection = gitlab_repositories.map do |repo|
        [repo["path_with_namespace"], repo["id"]] unless configured_repositories.include?(repo["id"].to_s)
      end.compact

      collection.sort_by { |k| k.first["path_with_namespace"] }
    end

    def find_gitlab_repo_by_id(id)
      gitlab_repositories.find { |repo| repo["id"] == id }
    end

    def addons
      @_addons ||= Addon.pluck(:name, :id)
    end

    private

    def configured_repositories
      @configured_repo_ids ||= @project.repositories.pluck(:integration_id)
    end

    def gitlab_repositories
      return [] if project.project_record.gitlab_repositories_info.blank?

      project.project_record.gitlab_repositories_info.data
    end
  end
end
