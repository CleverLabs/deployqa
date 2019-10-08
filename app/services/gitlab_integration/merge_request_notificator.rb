# frozen_string_literal: true

module GitlabIntegration
  class MergeRequestNotificator
    def initialize(project_instance)
      @project_instance = project_instance
    end

    def call(text)
      repository = @project_instance.project.repositories.find_by(path: @project_instance.attached_repo_path)
      merge_request = GitlabIntegration::MergeRequest.new(repository.integration_id, @project_instance.attached_pull_request_number)
      merge_request.update_info_comment(text)
    end
  end
end
