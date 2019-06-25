# frozen_string_literal: true

class ProjectUserRolesController < ApplicationController
  def destroy
    project = find_project
    role = ProjectUserRole.find(params[:id])
    role.destroy!
    redirect_to project_path(project)
  end

  private

  def find_project
    Project.find(params[:project_id])
  end
end
