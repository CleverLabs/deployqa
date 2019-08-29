# frozen_string_literal: true

class ProjectCreator
  PROJECT_CREATOR_STRATEGIES = {
    ProjectsConstants::Providers::VIA_SSH => SshIntegration::ProjectCreator,
    ProjectsConstants::Providers::GITLAB => GitlabIntegration::ProjectCreator
  }.freeze

  def initialize(controller_params, current_user)
    @controller_params = controller_params
    @current_user = current_user
  end

  def call
    strategy = PROJECT_CREATOR_STRATEGIES.fetch(controller_params[:integration_type])
    strategy.new(controller_params, current_user).call
  end

  private

  attr_reader :controller_params, :current_user
end
