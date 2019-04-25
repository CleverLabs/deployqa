# frozen_string_literal: true

class ReposController < ApplicationController
  def create
    redirect_to root_path if Repo.exists?(path: params[:repo])
    repo = current_user.repos.create(path: params[:repo])
    DeployKeysWorkflow.new(repo).call
  end

  def show
    @repo = Repo.find(params[:id])
  end

  def index
    @github_repos = Github::Repos.new(current_user).receive
  end
end
