# frozen_string_literal: true

class LandingsController < ApplicationController
  CACHE_KEY = SecureRandom.uuid

  skip_before_action :login_if_not

  layout "landing"

  caches_page :roles, :pricing, :faq
  caches_action :index, if: -> { !authenticated? }, cache_path: -> { "cached-views.landings#index.#{CACHE_KEY}" }, expires_in: 7.days

  def index
    return redirect_to next_page_path if authenticated? && Rails.env.production?
  end

  def roles
    @role_name = params[:role]
    raise unless %w[for-managers for-qa for-sales for-developers].include? @role_name

    @texts = I18n.t("landing.roles.#{@role_name}.how-it-helps")
  end

  def pricing; end

  def faq; end

  def create
    return redirect_to("/") if params[:email].blank?

    WaitingList.create(email: params[:email])
    render :done
  end

  private

  def next_page_path
    project = find_projects.first
    project ? project_project_instances_path(project) : projects_path
  end

  def find_projects
    statuses = ProjectInstanceConstants::Statuses::ALL_ACTIVE.map { |status| ProjectInstance.deployment_statuses[status] }.join(", ")

    Project
      .select("projects.*, COUNT(project_instances) as active_instances")
      .joins("LEFT JOIN project_instances ON project_instances.project_id = projects.id AND project_instances.deployment_status in (#{statuses})")
      .joins(:project_user_roles)
      .where(project_user_roles: { user_id: current_user.id })
      .group("projects.id")
      .order("projects.created_at DESC")
  end
end
