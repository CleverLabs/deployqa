# frozen_string_literal: true

class GithubUserClient
  delegate :find_user_installations, to: :@client

  def initialize(user_token)
    @client = Octokit::Client.new(access_token: user_token)
  end
end
