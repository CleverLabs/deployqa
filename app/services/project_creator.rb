# frozen_string_literal: true

class ProjectCreator
  def initialize(controller_params, current_user)
    @controller_params = controller_params
    @current_user = current_user
  end

  def call
    ActiveRecord::Base.transaction do
      project = Project.new(project_params)
      project.project_user_roles.build(user: current_user, role: ProjectUserRoleConstants::ADMIN)
      project.save
      ReturnValue.new(object: project, status: project.errors.any? ? :error : :ok)
    end
  end

  private

  attr_reader :controller_params, :current_user

  def project_params
    meaningless_integration_id = SecureRandom.uuid

    controller_params.merge(SshKeys.new.generate) if controller_params[:integration_type] == ProjectsConstants::Providers::VIA_SSH
    controller_params.merge(integration_id: meaningless_integration_id) unless controller_params[:integration_type] == ProjectsConstants::Providers::GITHUB
    controller_params
  end
end
