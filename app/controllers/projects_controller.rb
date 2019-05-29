# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = Project.all
                       .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id")
                       .group("projects.id").select("projects.*, COUNT(project_instances) as builds")
                       .order("projects.created_at DESC")
  end

  def new
    @project = Project.new
  end

  def show
    @project = find_project
    @deployment_configurations = @project.deployment_configurations
  end

  def create
    # TODO: change github_secret_token
    @project = Project.new(project_params.merge(owner: current_user, github_secret_token: "12345"))

    if @project.save
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  private

  def find_project
    Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
