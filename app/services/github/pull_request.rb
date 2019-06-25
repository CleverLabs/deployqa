# frozen_string_literal: true

module Github
  class PullRequest
    def initialize(installation_id, repo_path, pull_request_number)
      @repo_path = repo_path
      @pull_request_number = pull_request_number
      @client = GithubAppClient.new(installation_id)
    end

    def add_to_first_comment(text)
      original_text = @client.issue(@repo_path, @pull_request_number).body
      new_text = [original_text, "\n", text].join
      @client.update_issue(@repo_path, @pull_request_number, body: new_text)
    end

    def update_info_comment(text)
      comment = @client.issue_comments(@repo_path, @pull_request_number).reverse.find { |issue| issue.user.login == @client.login }
      comment ? @client.update_comment(@repo_path, comment.id, text) : @client.add_comment(@repo_path, @pull_request_number, text)
    end
  end
end
