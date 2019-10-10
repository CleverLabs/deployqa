# frozen_string_literal: true

require "clone_repo"

class GitWrapper
  TEMP_FOLDER = "tmp"

  def self.clone_by_ssh(repo_path, private_key)
    clone_repo = CloneRepo.new(repo_path, private_key).tap(&:call)
    new(Git.open(clone_repo.repo_dir))
  end

  def self.clone_by_uri(repo_path, repo_uri)
    repo_name = [*repo_path.split("/"), SecureRandom.hex(4)].join("-")
    new(Git.clone(repo_uri, repo_name, path: TEMP_FOLDER))
  end

  def initialize(git_client)
    @git_client = git_client
    @repo_dir = git_client.dir.to_s

    configure_git
  end

  def add_file(content:, filename:)
    create_file(content, filename)
    commit_file(filename)
    ReturnValue.ok
  end

  def add_remote_heroku(heroku_app_name)
    @git_client.add_remote("heroku", "https://heroku:#{ENV['HEROKU_API_KEY']}@git.heroku.com/#{heroku_app_name}.git")
    ReturnValue.ok
  end

  def select_branch(branch)
    @git_client.fetch("origin")
    @git_client.reset_hard("origin/master")
    @git_client.checkout(branch.to_s)
    @git_client.pull("origin", branch)
    ReturnValue.ok
  end

  def push_heroku(branch)
    @git_client.push("heroku", "#{branch}:master", f: true)
    ReturnValue.ok
  end

  def remove_dir
    FileUtils.rm_rf(@repo_dir)
    ReturnValue.ok
  end

  private

  def configure_git
    @git_client.config("user.name", "DeployQA")
    @git_client.config("user.email", "deployqa@cleverlabs.io")
    @git_client.config("commit.gpgsign", "false")
  end

  def create_file(content, filename)
    procfile = File.new(File.join(@repo_dir, filename), "w")
    procfile.write(content)
    procfile.close
  end

  def commit_file(filename)
    @git_client.add(filename)
    @git_client.commit("Add #{filename}")
  end
end
