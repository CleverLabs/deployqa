# frozen_string_literal: true

module Github
  class PullRequestNotificator
    def initialize(project_instance)
      @project = project_instance.project
      @project_instance = project_instance
    end

    def call(text)
      pull_request = Github::PullRequest.new(@project.integration_id,
                                             @project_instance.attached_repo_path,
                                             @project_instance.attached_pull_request_number)
      pull_request.update_info_comment(text)
    end
  end
end
