# frozen_string_literal: true

class RepositoryStatusesController < ApplicationController
  def update
    project = find_project
    project.repositories.find(params[:id]).update!(status: params[:status])
    redirect_to project_path(project)
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end
end
