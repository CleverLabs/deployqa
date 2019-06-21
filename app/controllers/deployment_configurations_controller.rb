# frozen_string_literal: true

class DeploymentConfigurationsController < ApplicationController
  before_action :authorize_project_admin

  def new
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build
  end

  def create
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build(deployment_configuration_params)
    form = DeploymentConfigurationForm.new(deployment_configuration_params.merge(project: @project))

    if @deployment_configuration.update(form.attributes)
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def edit
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.find(params[:id])
  end

  def update
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.find(params[:id])
    form = DeploymentConfigurationForm.new(deployment_configuration_params.merge(project: @project, integration_id: @deployment_configuration.integration_id))

    if @deployment_configuration.update(form.attributes)
      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  def destroy
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.find(params[:id])

    @deployment_configuration.destroy!
    redirect_to project_path(@project)
  end

  private

  def find_project
    @_project ||= Project.find(params[:project_id])
  end

  def deployment_configuration_params
    params.require(:deployment_configuration).permit(:repo_path, :env_variables)
  end

  def authorize_project_admin
    authorize find_project, :edit?, policy_class: ProjectPolicy
  end
end
