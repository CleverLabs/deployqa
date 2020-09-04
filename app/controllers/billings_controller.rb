# frozen_string_literal: true

class BillingsController < ApplicationController
  def index
    @project = find_project
    @lifecycles, @total_cost = Billing::Processes::CurrentMonth.new(@project, date: DateTime.now).call
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :billing?, policy_class: ProjectPolicy
  end
end
