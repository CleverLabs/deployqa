# frozen_string_literal: true

require "fileutils"

class CloneRepo
  TEMP_FOLDER = "tmp"
  TEMP_KEYS_DIR = "keys"
  SSH_ENV = "GIT_SSH_COMMAND"
  SSH_COMMAND = "ssh -i %<keypath>s"
  CLONE_COMMAND = "git clone %<git_path>s %<dest>s"

  def initialize(repo_path, private_key)
    @repo_path = repo_path
    @private_key = private_key
  end

  def call
    with_env do |key|
      Open3.capture3(
        { SSH_ENV => format(SSH_COMMAND, keypath: key) },
        format(CLONE_COMMAND, git_path: @repo_path, dest: repo_dir)
      )
    end
  end

  def repo_dir
    @_repo_dir ||= File.join(TEMP_FOLDER, [
      *@repo_path.split("/"),
      SecureRandom.hex(4)
    ].join("-"))
  end

  private

  def with_env
    key = write_temp_key!
    yield(key)
  ensure
    File.delete(key)
  end

  def write_temp_key!
    FileUtils.mkdir_p(File.join(TEMP_FOLDER, TEMP_KEYS_DIR))
    filename = File.join(TEMP_FOLDER, TEMP_KEYS_DIR, SecureRandom.hex(16))
    File.write(filename, @private_key)
    File.new(filename).chmod(0o600)
    Pathname.new(filename).realpath.to_s
  end
end
