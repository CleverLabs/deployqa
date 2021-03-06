# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def create?
    user.system_role != UserConstants::SystemRoles::GUEST
  end

  def edit?
    project_admin?
  end

  def show?
    project_member?
  end

  def create_instance?
    show_create_instance_page? && record.billing.can_create_instance?
  end

  def show_create_instance_page?
    return false unless show?

    record.project_record.repositories.where(status: RepositoryConstants::ACTIVE).limit(1).present? # Limit 1, to make sure at least one active repository exist
  end

  def billing?
    project_admin?
  end

  private

  def project_admin?
    ProjectUserRole.find_by(user_id: user.id, project_id: record.id, role: ProjectUserRoleConstants::ADMIN).present?
  end

  def project_member?
    ProjectUserRole.find_by(user_id: user.id, project_id: record.id).present?
  end
end
