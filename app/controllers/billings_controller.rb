# frozen_string_literal: true

class BillingsController < ApplicationController
  def index
    @project = find_project

    timeframe = Billing::Lifecycle::Timeframe.current_month(DateTime.now.beginning_of_month)
    @lifecycles = Billing::Lifecycle::InstanceLifecycleGenerator.new(@project, nil, timeframe).call
    @total_cost = Billing::Invoice::CostsCalculator.new(@lifecycles, timeframe).call
  end

  private

  def find_project
    authorize Project.find(params[:project_id]), :billing?, policy_class: ProjectPolicy
  end
end
