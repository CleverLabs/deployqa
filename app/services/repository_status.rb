# frozen_string_literal: true

class RepositoryStatus
  def initialize(project)
    @project = project
  end

  def active?(repo_path)
    @project.repositories.find_by(repo_path: repo_path).status == RepositoryConstants::ACTIVE
  end
end
