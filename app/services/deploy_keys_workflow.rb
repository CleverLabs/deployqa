# frozen_string_literal: true

# TODO: Remove? It is not used
class DeployKeysWorkflow
  COMMENT = "Deployqa key"

  def initialize(deployment_configuration, user)
    @deployment_configuration = deployment_configuration
    @user = user
  end

  def call
    @deployment_configuration.update!(ssh_keys)
    client.add_deploy_key(
      @deployment_configuration.repo_path,
      COMMENT,
      ssh_keys.fetch(:public_key),
      read_only: true
    )
  end

  private

  def ssh_keys
    @_ssh_keys ||= SshKeys.new.generate
  end

  def client
    @_client ||= Octokit::Client.new(access_token: @user.token)
  end
end
