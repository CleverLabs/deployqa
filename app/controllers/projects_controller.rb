# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    statuses = ProjectInstanceConstants::ACTIVE_INSTANCES.map { |status| ProjectInstance.deployment_statuses[status] }.join(", ")
    @projects = Project.all
                       .select("projects.*, COUNT(project_instances) as builds")
                       .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id AND project_instances.deployment_status in (#{statuses})")
                       .group("projects.id")
                       .order("projects.created_at DESC")
  end

  def new
    @project = Project.new
  end

  def show
    @project = find_project
    authorize @project, :edit?, policy_class: ProjectPolicy
    @deployment_configurations = @project.deployment_configurations.order(:status)
    @roles = @project.project_user_roles.includes(:user)
    @project_github_entity = GithubEntity.find_by(owner: @project) if @project.integration_type == ProjectsConstants::Providers::GITHUB
  end

  def create
    result = ProjectCreator.new(project_params, current_user).call
    @project = result.object

    if result.ok?
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
