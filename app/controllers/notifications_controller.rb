# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    @project = find_project
  end

  private

  def find_project
    authorize ProjectDomain.by_id(params[:project_id]), :edit?, policy_class: ProjectPolicy
  end
end
