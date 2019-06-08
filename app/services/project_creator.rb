# frozen_string_literal: true

class ProjectCreator
  def initialize(controller_params, current_user)
    @params = controller_params
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

  attr_reader :params, :current_user

  def project_params
    # TODO: change github_secret_token
    params.merge(github_secret_token: "12345")
  end
end
