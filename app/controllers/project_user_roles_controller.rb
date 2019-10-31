# frozen_string_literal: true

class ProjectUserRolesController < ApplicationController
  def destroy
    project = find_project
    project.project_user_roles.find(params[:id]).destroy!
    redirect_to project_path(project)
  end

  def create
    project = find_project
    user = find_user(project)

    unless user
      flash.notice = "User not found"
      return redirect_to project_path(project)
    end

    project.project_user_roles.create!(project_user_role_params.merge(user_id: user.id))
    redirect_to project_path(project)
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end

  def find_user(project)
    User
      .joins(:auth_info)
      .where(auth_provider: project.integration_type) # TODO: remove when we will merge users with different providers
      .find_by("auth_infos.data->>'email' = ?", params[:project_user_role][:email])
  end

  def project_user_role_params
    params.require(:project_user_role).permit(:role)
  end
end
