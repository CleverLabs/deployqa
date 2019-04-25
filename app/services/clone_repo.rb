# frozen_string_literal: true

require "fileutils"

class CloneRepo
  TEMP_FOLDER = "tmp"
  TEMP_KEYS_DIR = "keys"
  SSH_ENV = "GIT_SSH_COMMAND"
  SSH_COMMAND = "ssh -i %<keypath>s"
  CLONE_COMMAND = "git clone %<git_path>s %<dest>s"
  GITHUB_URL = "git@github.com:%<repo_path>s.git"

  def initialize(repo)
    @repo = repo
  end

  def self.with_repo(repo)
    clone = new(repo)
    clone.call
    yield(clone.repo_dir) if block_given?
  ensure
    FileUtils.rm_rf(clone.repo_dir)
  end

  def call
    with_env do |key|
      Open3.capture3(
        { SSH_ENV => format(SSH_COMMAND, keypath: key) },
        format(CLONE_COMMAND, git_path: ssh_url, dest: repo_dir)
      )
    end
  end

  def repo_dir
    @_repo_dir ||= File.join(TEMP_FOLDER, [
      *@repo.path.split("/"),
      SecureRandom.hex(4)
    ].join("-"))
  end

  private

  def ssh_url
    format(GITHUB_URL, repo_path: @repo.path)
  end

  def with_env
    key = write_temp_key!
    yield(key)
  ensure
    File.delete(key)
  end

  def write_temp_key!
    FileUtils.mkdir_p(File.join(TEMP_FOLDER, TEMP_KEYS_DIR))
    filename = File.join(TEMP_FOLDER, TEMP_KEYS_DIR, SecureRandom.hex(16))
    File.write(filename, @repo.private_key)
    File.new(filename).chmod(0o600)
    Pathname.new(filename).realpath.to_s
  end
end
