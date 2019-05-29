# frozen_string_literal: true

class DeploymentConfigurationsController < ApplicationController
  def new
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build
  end

  def create
    @project = find_project
    @deployment_configuration = @project.deployment_configurations.build(deployment_configuration_params)

    if @deployment_configuration.save
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

    if @deployment_configuration.update(deployment_configuration_params)
      redirect_to project_path(@project)
    else
      render :edit
    end
  end

  private

  def find_project
    Project.find(params[:project_id])
  end

  def deployment_configuration_params
    params.require(:deployment_configuration).permit(:name, :repo_path, :env_variables).tap do |result|
      result[:env_variables] = Hash[result[:env_variables].split("\n").map { |line| line.tr("\r", "").split(": ") }]
    end
  end
end
