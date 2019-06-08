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

    if @deployment_configuration.save
      DeployKeysWorkflow.new(@deployment_configuration, current_user).call
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
    params.require(:deployment_configuration).permit(:repo_path, :env_variables).tap do |result|
      result[:env_variables] = Hash[result[:env_variables].split("\n").map { |line| line.tr("\r", "").split(": ") }]
      result[:name] = result[:repo_path].split("/").last
    end
  end

  def authorize_project_admin
    authorize find_project, :edit?, policy_class: ProjectPolicy
  end
end
