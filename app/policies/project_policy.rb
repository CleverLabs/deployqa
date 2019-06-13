# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def edit?
    project_admin?
  end

  def show?
    project_member?
  end

  private

  def project_admin?
    ProjectUserRole.find_by(user_id: user.id, project_id: record.id, role: ProjectUserRoleConstants::ADMIN).present?
  end

  def project_member?
    ProjectUserRole.find_by(user_id: user.id, project_id: record.id).present?
  end
end
