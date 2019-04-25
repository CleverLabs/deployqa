# frozen_string_literal: true

module Github
  class PullRequest
    def initialize(path, number)
      @path = path
      @number = number
    end

    delegate :title, to: :pull_request

    private

    def pull_request
      @pull_request ||= client.pull_request(@path, @number)
    end

    def client
      @client ||= Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
    end
  end
end
