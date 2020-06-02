# frozen_string_literal: true

class ProjectInstanceDomain
  attr_reader :project_instance_record, :deployment_configurations

  delegate :id, :project_id, :name, :deployment_status, :attached_pull_request_number, :attached_repo_path, :build_actions, :to_param, :flipper_id, :present?, to: :project_instance_record

  def self.by_sleep_url(application_name)
    # instance = ProjectInstance.where(deployment_status: ProjectInstanceConstants::Statuses::SLEEP).includes(:build_actions).find_each.find do |project_instance|
    #   self.new(record: project_instance).configurations.any? { |configuration| configuration.application_name == application_name }
    # end

    # self.new(record: instance)

    instance = SleepingInstance.find_by(application_name: application_name)&.project_instance
    instance = SleepingInstance.last if !instance && application_name == "localhost:8000"
    raise ActiveRecord::RecordNotFound, "Sleeping instance with name #{application_name} not found!" unless instance

    new(record: instance.project_instance)
  end

  def self.create(project_id:, name:, deployment_status:, branches:, attached_pull_request: {})
    record = ProjectInstance.create(
      project_id: project_id,
      deployment_status: deployment_status,
      name: name,
      attached_repo_path: attached_pull_request[:repo],
      attached_pull_request_number: attached_pull_request[:number],
      branches: branches
    )

    ReturnValue.new(object: new(record: record), status: record.errors.any? ? :error : :ok)
  end

  def initialize(id: nil, record: nil)
    @project_instance_record = record || (id ? ProjectInstance.find(id) : nil)
  end

  def last_action_record
    @last_action_record ||= begin
      scope = @project_instance_record.build_actions
      scope.loaded? ? scope.max_by(&:created_at) : scope.order(:created_at).last
    end
  end

  def action_status
    last_action_record.status
  end

  def create_action!(author:, action:, configurations_to_update: nil, docker_deploy_lambda: nil)
    previous_action = last_action_record
    @last_action_record = BuildAction.create!(project_instance: @project_instance_record, author: author, action: action, configurations: [], status: BuildActionConstants::Statuses::SCHEDULED)
    @deployment_configurations = if BuildActionConstants::NEW_INSTANCE_ACTIONS.include?(action)
                                   create_configurations(@last_action_record.id, docker_deploy_lambda)
                                 else
                                   duplicate_configurations(previous_action, configurations_to_update, @last_action_record)
                                 end

    @last_action_record.update!(configurations: @deployment_configurations.map(&:to_project_instance_configuration))
    @last_action_record
  end

  def update_status!(status)
    @project_instance_record.update!(deployment_status: status)
  end

  def update_branches(branches)
    @project_instance_record.update(branches: branches)
  end

  def configurations
    last_action_record&.configurations || []
  end

  private

  delegate :branches, to: :project_instance_record

  def create_configurations(build_action_id, docker_deploy_lambda)
    features_accessor = Features::Accessor.new
    Deployment::ConfigurationBuilders::ByProject.new(
      @project_instance_record.project,
      build_action_id,
      docker_deploy_lambda || -> { features_accessor.docker_deploy_allowed?(@project_instance_record.project) }
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
