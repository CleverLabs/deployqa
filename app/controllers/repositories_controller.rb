# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def new
    @project = find_project
    @repository = @project.repositories.build
    @addons = Addon.pluck(:name, :id)
  end

  def create
    @project = find_project
    @repository = @project.repositories.build
    form = RepositoryForm.new(repository_params.merge(project: @project.project_record))

    if @repository.update(form.attributes)
      redirect_to project_path(@project)
    else
      @addons = Addon.pluck(:name, :id)
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
    authorize ProjectDomain.by_id(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end

  def repository_params
    params.require(:repository).permit(
      :path, :build_type, :schema_load_command, :migration_command, :seeds_command,
      addon_ids: [],
      web_processes_attributes: %i[id name command dockerfile expose_port],
      runtime_env_variables: {}, build_env_variables: {}
    )
  end

  def update_repo
    form = RepositoryForm.new(repository_params.merge(project: @project.project_record, integration_id: @repository.integration_id, status: @repository.status))
    destroy_deleted_web_processes(form)
    if @project.integration_type == ProjectsConstants::Providers::VIA_SSH
      @repository.update(form.attributes.except(:name, :path))
    else
      @repository.update(
        form.attributes.slice(:runtime_env_variables, :build_env_variables, :addon_ids, :web_processes_attributes, :build_type, :status, :seeds_command, :schema_load_command, :migration_command)
      )
    end
  end

  def destroy_deleted_web_processes(form)
    not_selected_processes = @repository.web_processes.map(&:id) - form.web_processes_attributes.map { |attributes| attributes["id"].to_i }
    return if not_selected_processes.blank?

    WebProcess.where(id: not_selected_processes).destroy_all
  end
end
