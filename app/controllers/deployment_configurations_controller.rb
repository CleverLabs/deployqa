# frozen_string_literal: true

class DeploymentConfigurationsController < ApplicationController
  def new
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build
  end

  def create
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build
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

    if update_configuration
      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end

  def deployment_configuration_params
    params.require(:deployment_configuration).permit(:repo_path, :env_variables)
  end

  def update_configuration
    form = DeploymentConfigurationForm.new(deployment_configuration_params.merge(project: @project, integration_id: @deployment_configuration.integration_id))
    if @project.integration_type == ProjectsConstants::Providers::VIA_SSH
      @deployment_configuration.update(form.attributes)
    else
      @deployment_configuration.update(form.attributes.slice(:env_variables))
    end
  end
end
