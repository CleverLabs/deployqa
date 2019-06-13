# frozen_string_literal: true

class GithubClient
  delegate :login, :issue, :update_issue, :issue_comments, :update_comment, :add_comment, to: :client

  def initialize(installation_id)
    @installation_id = installation_id
    @token_time = nil
    @client = nil
  end

  def repo_uri(repo_path)
    "https://x-access-token:#{client.access_token}@github.com/#{repo_path}.git"
  end

  private

  def client
    return @client if @token_time && (@token_time > Time.now.to_i)

    @token_time = (Time.now + 10.minutes).to_i
    @client = Octokit::Client.new(access_token: create_installation_token(@installation_id, @token_time))
  end

  def create_installation_token(installation_id, token_time)
    jwt_client = Octokit::Client.new(bearer_token: jwt_auth_token(token_time))
    jwt_client.create_app_installation_access_token(installation_id, accept: "application/vnd.github.machine-man-preview+json").token
  rescue StandardError => error
    puts error
    puts error.response.data[:body]
  end

  def jwt_auth_token(token_time)
    private_key = OpenSSL::PKey::RSA.new(ENV["GITHUB_APP_KEY"])

    payload = {
      iat: (token_time - 10.minutes).to_i,
      exp: token_time,
      iss: ENV["GITHUB_APP_ID"]
    }

    JWT.encode(payload, private_key, "RS256")
  end
end
