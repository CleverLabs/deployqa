# frozen_string_literal: true

require "clone_repo"

class GitWrapper
  TEMP_FOLDER = "tmp"
  PROCFILE_NAME = "Procfile"

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

  def add_procfile(web_processes)
    return if web_processes.blank?

    generate_procfile(web_processes)
    commit_procfile
    ReturnValue.ok
  end

  def add_remote_heroku(heroku_app_name)
    @git_client.add_remote("heroku", "https://git.heroku.com/#{heroku_app_name}.git")
    ReturnValue.ok
  end

  def push_heroku(branch)
    @git_client.fetch("origin")
    @git_client.reset_hard("origin/master")
    @git_client.checkout(branch.to_s)
    @git_client.pull("origin", branch)
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

  def generate_procfile(web_processes)
    file_text = web_processes.map(&:to_procfile_command).join("\n")
    procfile = File.new(File.join(@repo_dir, PROCFILE_NAME), "w")
    procfile.write(file_text)
    procfile.close
  end

  def commit_procfile
    @git_client.add(PROCFILE_NAME)
    @git_client.commit("Add procfile")
  end
end
