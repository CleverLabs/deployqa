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
      gitlab_repositories.map { |repo| [repo["path_with_namespace"], repo["id"]] }
    end

    def find_gitlab_repo_by_id(id)
      gitlab_repositories.find { |repo| repo["id"] == id }
    end

    def addons
      @_addons ||= Addon.pluck(:name, :id)
    end

    private

    def gitlab_repositories
      return [] if project.gitlab_repositories_info.blank?

      project.gitlab_repositories_info.data
    end
  end
end
