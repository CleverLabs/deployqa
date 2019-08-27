# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def new
    @project = find_project
    @repository = @project.repositories.build
  end

  def create
    @project = find_project
    @repository = @project.repositories.build
    form = RepositoryForm.new(repository_params.merge(project: @project))

    if @repository.update(form.attributes)
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def edit
    @project = find_project
    @repository = @project.repositories.find(params[:id])
    @addons = Addon.pluck(:name, :id)
  end

  def update
    @project = find_project
    @repository = @project.repositories.find(params[:id])

    if update_repo
      redirect_to project_path(@project)
    else
      @addons = Addon.pluck(:name, :id)
      render :edit
    end
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end

  def repository_params
    params.require(:repository).permit(:path, :env_variables, addon_ids: [], web_processes_attributes: %i[id name command])
  end

  def update_repo
    form = RepositoryForm.new(repository_params.merge(project: @project, integration_id: @repository.integration_id))
    if @project.integration_type == ProjectsConstants::Providers::VIA_SSH
      @repository.update(form.attributes)
    else
      @repository.update(form.attributes.slice(:env_variables, :addon_ids, :web_processes_attributes))
    end
  end
end
