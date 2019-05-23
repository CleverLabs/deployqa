# frozen_string_literal: true

require "clone_repo"

class GitWrapper
  def self.clone(repo_path, private_key)
    clone_repo = CloneRepo.new(repo_path, private_key).tap(&:call)
    new(Git.open(clone_repo.repo_dir), clone_repo.repo_dir)
  end

  def initialize(git_client, repo_dir)
    @git_client = git_client
    @repo_dir = repo_dir
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
