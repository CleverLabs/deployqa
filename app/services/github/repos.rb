# frozen_string_literal: true

module Github
  class Repos
    GithubRepo = Struct.new(:name, :url, :private, :id)

    def initialize(user)
      @user = user
      @token = user.token
    end

    def receive
      client.repos.map { |repo| present(repo) }
    end

    private

    def present(repo)
      GithubRepo.new(
        repo.full_name,
        repo.html_url,
        repo.private,
        user_repos[repo.full_name]
      )
    end

    def user_repos
      @_user_repos ||= @user.repos.pluck(:path, :id).to_h
    end

    def client
      @_client ||= Octokit::Client.new(access_token: @token).tap do |octokit|
        octokit.auto_paginate = true
      end
    end
  end
end
