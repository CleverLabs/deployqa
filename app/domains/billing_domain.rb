# frozen_string_literal: true

class BillingDomain
  attr_reader :billing_info_record

  delegate :active?, to: :billing_info_record

  def self.create!(project:, application_plan: nil)
    application_plan ||= ApplicationPlan.find_by(name: "trial")
    billing_info = BillingInfo.create!(
      project: project.project_record,
      application_plan: application_plan,
      sleep_cents: application_plan.sleep_cents,
      run_cents: application_plan.run_cents,
      build_cents: application_plan.build_cents
    )

    new(billing_info, project)
  end

  def self.by_project(project)
    new(project.billing_info, project)
  end

  def initialize(billing_info, project)
    @billing_info_record = billing_info
    @project = project
  end

  def max_allowed_instances
    @billing_info_record.application_plan.max_allowed_instances
  end

  def pricing_by_types
    @billing_info_record.slice(:sleep_cents, :run_cents, :build_cents)
  end

  def can_create_instance?
    return false unless active?

    @project.number_of_active_instances < @billing_info_record.application_plan.max_allowed_instances
  end
end
