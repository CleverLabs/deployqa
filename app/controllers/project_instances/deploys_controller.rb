# frozen_string_literal: true

module ProjectInstances
  class DeploysController < ApplicationController
    def show
      @project = find_project
      @project_instance = find_project_instance(@project)
      @repositories = find_available_repositories

      return redirect_to_instance_with_error unless ProjectInstancePolicy.new(current_user, @project_instance).deploy_by_link?
      return if params[:custom_deploy]

      deploy(@project_instance)
      redirect_to GitProviders::URL::PullMergeRequest.new(@project_instance, @project.integration_type).call
    end

    def create
      @project = find_project
      @project_instance = find_project_instance(@project)

      return redirect_to_instance_with_error unless ProjectInstancePolicy.new(current_user, @project_instance).deploy_by_link?

      if @project_instance.update_branches(branches_params)
        deploy(@project_instance)
        redirect_to project_project_instance_path(@project, @project_instance)
      else
        @repositories = find_available_repositories
        render :show
      end
    end

    private

    def find_project
      authorize ProjectDomain.by_id(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      project.project_instance(id: params[:project_instance_id])
    end

    def find_available_repositories
      @project.project_record.repositories.active
    end

    def redirect_to_instance_with_error
      flash.notice = "Application already deployed"
      redirect_to project_project_instance_path(@project, @project_instance)
    end

    def branches_params
      params.require(:project_instance).require(:configurations).permit!
    end

    def deploy(project_instance)
      Deployment::Processes::DeployNewInstance.new(@project, project_instance).call(current_user.user_reference)
    end
  end
end
