# frozen_string_literal: true

require "clone_repo"

class GitWrapper
  TEMP_FOLDER = "tmp"

  def self.clone(repo_path, repo_uri)
    repo_name = [*repo_path.split("/"), SecureRandom.hex(4)].join("-")
    new(Git.clone(repo_uri, repo_name, path: TEMP_FOLDER))
  end

  def initialize(git_client)
    @git_client = git_client
    @repo_dir = git_client.dir.to_s
  end

  def add_remote_heroku(heroku_app_name)
    @git_client.add_remote("heroku", "https://git.heroku.com/#{heroku_app_name}.git")
  end

  def push_heroku(branch)
    @git_client.branch(branch.to_s).checkout
    @git_client.pull("origin", branch)
    @git_client.push("heroku", "#{branch}:master", f: true)
  end

  def remove_dir
    FileUtils.rm_rf(@repo_dir)
  end
end
