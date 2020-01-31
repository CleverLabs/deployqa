# frozen_string_literal: true

class ProjectUserRolesController < ApplicationController
  def destroy
    project = find_project
    project.project_user_roles.find(params[:id]).destroy!
    redirect_to project_path(project)
  end

  def create
    project = find_project
    user = find_user

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

  def find_user
    User
      .joins(user_references: :auth_info)
      .where(auth_infos: { email: params[:project_user_role][:email] })
      .first
  end

  def project_user_role_params
    params.require(:project_user_role).permit(:role)
  end
end
