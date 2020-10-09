# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = find_projects
    @installing_project = Project.new(integration_type: ProjectsConstants::Providers::GITHUB) if project_installing?
  end

  def new
    authorize :project, :create?, policy_class: ProjectPolicy

    @provider = find_provider
    @project = Project.new
  end

  def show
    @project = find_project
    @repositories = @project.project_record.repositories.order(:name)
    @roles = @project.project_record.project_user_roles.includes(:user)
    @project_github_entity = GithubEntity.find_by(owner: @project.project_record) if @project.integration_type == ProjectsConstants::Providers::GITHUB

    render :show, layout: "application_new"
  end

  def create
    authorize :project, :create?, policy_class: ProjectPolicy

    result = SshIntegration::ProjectCreator.new(project_params, current_user).call
    @project = result.object

    if result.ok?
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  private

  def find_provider
    raise "Wrong provider" unless ProjectsConstants::Providers::ALL.include?(params[:provider])

    params[:provider]
  end

  def find_project
    authorize ProjectDomain.by_id(params[:id]), :edit?, policy_class: ProjectPolicy
  end

  def find_projects
    statuses = ProjectInstanceConstants::Statuses::ALL_ACTIVE.map { |status| ProjectInstance.deployment_statuses[status] }.join(", ")

    Project
      .select("projects.*, COUNT(project_instances) as active_instances")
      .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id AND project_instances.deployment_status in (#{statuses})")
      .joins(:project_user_roles)
      .where(project_user_roles: { user_id: current_user.id })
      .group("projects.id")
      .order("projects.created_at DESC")
      .includes(:repositories)
  end

  def project_installing?
    return false unless params[:installation_id]

    !Project.find_by(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: params[:installation_id])
  end

  def project_params
    params.require(:project).permit(:name, :integration_type)
  end
end
