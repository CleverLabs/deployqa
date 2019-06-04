# frozen_string_literal: true

module Github
  class PullRequest
    def initialize(repo_path, pull_request_number)
      @repo_path = repo_path
      @pull_request_number = pull_request_number
      @client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
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

    delegate :title, to: :pull_request

    private

    def pull_request
      @pull_request ||= @client.pull_request(@repo_path, @pull_request_number)
    end
  end
end
