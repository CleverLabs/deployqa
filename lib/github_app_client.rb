# frozen_string_literal: true

class GithubAppClient
  delegate :login, :issue, :update_issue, :issue_comments, :update_comment, :add_comment, to: :client

  TOKEN_TIME_TO_LIVE = 9.minutes # 10 is max, used 9 to avoid Github errors

  def initialize(installation_id)
    @installation_id = installation_id
    @token_end_time = nil
    @client = nil
  end

  def repo_uri(repo_path)
    "https://x-access-token:#{client.access_token}@github.com/#{repo_path}.git"
  end

  private

  def client
    return @client unless expired?

    @token_end_time = (Time.now + TOKEN_TIME_TO_LIVE).to_i
    @client = Octokit::Client.new(access_token: create_installation_token)
  end

  def create_installation_token
    jwt_client = Octokit::Client.new(bearer_token: jwt_auth_token)
    jwt_client.create_app_installation_access_token(@installation_id, accept: "application/vnd.github.machine-man-preview+json").token
  rescue StandardError => error
    puts error
  end

  def jwt_auth_token
    private_key = OpenSSL::PKey::RSA.new(ENV["GITHUB_APP_KEY"])

    payload = {
      iat: (@token_end_time - TOKEN_TIME_TO_LIVE).to_i,
      exp: @token_end_time,
      iss: ENV["GITHUB_APP_ID"]
    }

    JWT.encode(payload, private_key, "RS256")
  end

  def expired?
    !@token_end_time || (@token_end_time <= Time.now.to_i)
  end
end
