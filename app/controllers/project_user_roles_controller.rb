# frozen_string_literal: true

class ProjectUserRolesController < ApplicationController
  def destroy
    project = find_project
    role = ProjectUserRole.find(params[:id])
    role.destroy!
    redirect_to project_path(project)
  end

  def create
    project = find_project
    project.project_user_roles.create!(project_user_role_params)
    redirect_to project_path(project)
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end

  def project_user_role_params
    params.require(:project_user_role).permit(:user_id, :role)
  end
end
