# frozen_string_literal: true

class ProjectInstanceDomain
  attr_reader :project_instance_record, :deployment_configurations

  delegate :id, :project_id, :name, :deployment_status, :attached_pull_request_number, :attached_repo_path, :build_actions, :to_param, :flipper_id, :present?, to: :project_instance_record
  delegate :configurations, to: :last_action_record

  def self.create(project_id:, name:, deployment_status:, branches:, attached_repo_path: nil, attached_pull_request_number: nil)
    record = ProjectInstance.create(
      project_id: project_id,
      deployment_status: deployment_status,
      name: name,
      attached_repo_path: attached_repo_path,
      attached_pull_request_number: attached_pull_request_number,
      branches: branches
    )

    ReturnValue.new(object: self.new(record: record), status: record.errors.any? ? :error : :ok)
  end

  def initialize(id: nil, record: nil)
    @project_instance_record = record ? record : ProjectInstance.find(id)
  end

  def last_action_record
    @last_action_record ||= @project_instance_record.build_actions.order(:created_at).last
  end

  def create_action!(author:, action:, configurations_to_update: nil)
    previous_action = last_action_record
    @last_action_record = BuildAction.create!(project_instance: @project_instance_record, author: author, action: action, configurations: [])
    if BuildActionConstants::NEW_INSTANCE_ACTIONS.include?(action)
      @deployment_configurations = create_configurations(author, @last_action_record.id)
    else
      @deployment_configurations = duplicate_configurations(previous_action, configurations_to_update, @last_action_record)
    end

    @last_action_record.update!(configurations: @deployment_configurations.map(&:to_project_instance_configuration))
    update_status!(ProjectInstanceConstants::SCHEDULED)
    @last_action_record
  end

  def update_status!(status)
    @project_instance_record.update!(deployment_status: status)
  end

  def update_branches(branches)
    @project_instance_record.update(branches: branches)
  end

  private

  delegate :branches, to: :project_instance_record

  def create_configurations(user_reference, build_action_id)
    features_accessor = Features::Accessor.new
    Deployment::ConfigurationBuilders::ByProject.new(
      @project_instance_record.project,
      build_action_id,
      ->() { features_accessor.docker_deploy_allowed?(user_reference.user, @project_instance_record.project) }
    ).call(name, branches)
  end

  def duplicate_configurations(previous_action, configurations_to_update, build_action)
    configurations = update_configurations_with_data(previous_action.configurations, configurations_to_update)
    Deployment::ConfigurationBuilders::ByProjectInstance.new(
      @project_instance_record.project,
      configurations,
      build_action.id,
      build_action.action
    ).call
  end

  def update_configurations_with_data(configurations, configurations_to_update)
    return configurations unless configurations_to_update

    configurations.map do |configuration|
      attributes = configuration.attributes
      configuration_to_update = configurations_to_update[configuration.application_name]
      configuration_to_update.each do |key, value|
        attributes[key] = value
      end
      configuration.class.new(attributes)
    end
  end
end
