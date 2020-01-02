# frozen_string_literal: true

class ProjectInstancesController < ApplicationController
  def index
    @project = find_project
    @project_instances = @project.project_instances.where.not(deployment_status: ProjectInstanceConstants::HIDDEN_INSTANCES).order(created_at: :desc)
    @new_instance_allowed = ProjectPolicy.new(current_user, @project).create_instance?
  end

  def show
    @project = find_project
    @project_instance = @project.project_instances.find(params[:id])
    @project_instance_policy = ProjectInstancePolicy.new(current_user, @project_instance)
  end

  def new
    @project = find_project
    @repositories = @project.repositories.active
    @project_instance = @project.project_instances.build
  end

  def create
    @project = find_project
    verify_creation_allowed(@project)

    result = create_project_instance(@project).call(project_instance_name: project_instance_name, branches: branches)

    if result.ok?
      redirect_to project_project_instance_path(@project, result.object)
    else
      @repositories = @project.repositories.active
      @project_instance = result.object
      render :new
    end
  end

  def destroy
    @project = find_project
    @project_instance = @project.project_instances.find(params[:id])

    Deployment::Processes::DestroyProjectInstance.new(@project_instance, current_user.user_reference).call
    redirect_to project_project_instances_path(@project)
  end

  private

  def verify_creation_allowed(project)
    authorize project, :create_instance?, policy_class: ProjectPolicy
  end

  def create_project_instance(project)
    Deployment::Processes::CreateManualProjectInstance.new(project, current_user.user_reference)
  end

  def find_project
    authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
  end

  def project_instance_name
    params.require(:project_instance).fetch(:name)
  end

  def branches
    params.require(:project_instance).fetch(:configurations)
  end
end
