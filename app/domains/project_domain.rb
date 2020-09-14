# frozen_string_literal: true

class ProjectDomain
  attr_reader :project_record

  delegate :id, :name, :integration_type, :integration_id, :repositories, :to_param, :flipper_id, :billing_info, to: :project_record

  def self.create!(integration_type:, integration_id:, name:)
    record = Project.find_or_create_by(integration_type: integration_type, integration_id: integration_id).tap do |project|
      project.update!(name: name) if project.name != name
    end

    new(record: record).tap { |project| BillingDomain.create!(project: project) }
  end

  def self.by_id(id)
    new(record: Project.find(id))
  end

  def self.by_integration(integration_type, integration_id)
    new(record: Project.find_by(integration_type: integration_type, integration_id: integration_id))
  end

  def initialize(record:)
    @project_record = record
  end

  def project_instance(id: nil, attached_pull_request_number: nil)
    raise if id.blank? && attached_pull_request_number.blank?

    record = id ? @project_record.project_instances.find_by(id: id) : @project_record.project_instances.find_by(attached_pull_request_number: attached_pull_request_number)
    ProjectInstanceDomain.new(record: record)
  end

  def billing
    @_billing ||= BillingDomain.by_project(self)
  end

  def active_repository?(repo_path)
    @project_record.repositories.find_by(path: repo_path).status == RepositoryConstants::ACTIVE
  end

  def number_of_active_instances
    @project_record.project_instances.where.not(deployment_status: ProjectInstanceConstants::Statuses::ALL_NOT_ACTIVE).count
  end
end
