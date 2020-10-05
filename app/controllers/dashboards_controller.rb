# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout "application_new"

  def show
    @project = find_project
    @project_instances = @project.project_record.project_instances.where.not(deployment_status: ProjectInstanceConstants::Statuses::ALL_NOT_ACTIVE).order(updated_at: :desc)
  end

  private

  def find_projects
    statuses = ProjectInstanceConstants::Statuses::ALL_ACTIVE.map { |status| ProjectInstance.deployment_statuses[status] }.join(", ")

    Project
      .select("projects.*, COUNT(project_instances) as active_instances")
      .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id AND project_instances.deployment_status in (#{statuses})")
      .joins(:project_user_roles)
      .where(project_user_roles: { user_id: current_user.id })
      .group("projects.id")
      .order("projects.created_at DESC")
      .includes(:repositories)
  end

  def find_project
    authorize ProjectDomain.by_id(6), :edit?, policy_class: ProjectPolicy
  end
end
