# frozen_string_literal: true

class ProjectInstancesController < ApplicationController
  def index
    @project = find_project
    @project_instances = @project.project_instances
  end

  def new
    @project = find_project
    @project_instance = @project.project_instances.build
  end

  def create
    @project = find_project
    result = Deployment::Processes::CreateProjectInstance.new(@project, current_user).call(project_instance_name: project_instance_name)

    if result.status == :ok
      redirect_to project_project_instance_path(@project, result.object)
    else
      @project_instance = result.object
      render :new
    end
  end

  def show
    @project = find_project
    @project_instance = @project.project_instances.find(params[:id])
  end

  def destroy
    @project = find_project
    @project_instance = @project.project_instances.find(params[:id])

    Deployment::Repositories::ProjectInstanceRepository.new(@project, @project_instance).update(deployment_status: :destroying_instances)
    destroy_instance(@project_instance)
    redirect_to project_project_instances_path(@project)
  end

  private

  def find_project
    Project.find(params[:project_id])
  end

  def project_instance_name
    params.require(:project_instance).fetch(:name)
  end

  def destroy_instance(project_instance)
    ServerActionsCallJob.perform_later(Deployment::ServerActions::Destroy.to_s, Deployment::Configuration.build_from_project_instance(project_instance).map(&:to_h))
  end
end
