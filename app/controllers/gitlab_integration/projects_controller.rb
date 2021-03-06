# frozen_string_literal: true

module GitlabIntegration
  class ProjectsController < ApplicationController
    layout "projectless_layout"

    def new
      @project = Project.new
      @names = GitlabIntegration::ProjectPage.new(current_user).build_project_names
    end

    def create
      result = GitlabIntegration::ProjectCreator.new(complete_project_params, current_user).call
      @project = result.object

      if result.ok?
        redirect_to project_path(@project)
      else
        @names = GitlabIntegration::ProjectPage.new(current_user).build_project_names
        render :new
      end
    end

    private

    def project_params
      params.require(:project).permit(:integration_id)
    end

    def complete_project_params
      project_params.merge(
        name: GitlabIntegration::ProjectPage.new(current_user).namespace_by_id(project_params[:integration_id]).path,
        integration_type: ProjectsConstants::Providers::GITLAB
      )
    end
  end
end
