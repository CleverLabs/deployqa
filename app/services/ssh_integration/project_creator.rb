# frozen_string_literal: true

module SshIntegration
  class ProjectCreator
    def initialize(controller_params, current_user)
      @project_params = build_project_params(controller_params)
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        project = Project.create!(project_params)
        create_project_user_role(project)
        ReturnValue.new(object: project, status: project.errors.any? ? :error : :ok)
      end
    end

    private

    attr_reader :project_params, :current_user

    def create_project_user_role(project)
      ProjectUserRole.create!(project: project, user_id: current_user.id, role: ProjectUserRoleConstants::ADMIN)
    end

    def build_project_params(controller_params)
      meaningless_integration_id = SecureRandom.uuid
      controller_params.merge(SshKeys.new.generate).merge(integration_id: meaningless_integration_id)
    end
  end
end
