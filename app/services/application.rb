# frozen_string_literal: true

class Application
  def initialize(repo, pull_id)
    @repo = repo
    @pull_id = pull_id
  end

  def slug
    [*@repo.path.split("/"), payload.number].join("-")
  end

  def branch
    payload.head.ref
  end

  def secrets
    @repo.secrets.map { |secret| { secret.key => secret.value } }.inject(:merge)
  end

  private

  def payload
    @_payload ||= client.pull_request(@repo.path, @pull_id)
  end

  def client
    @_client ||= Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
  end
end
