# frozen_string_literal: true

module ProjectInstances
  class DeploysController < ApplicationController
    layout "application_new"

    def show
      @project = find_project(action: :show_create_instance_page?)
      @project_instance = find_project_instance(@project)
      @billing = @project.billing
      @repositories = find_available_repositories

      return redirect_to project_project_instance_path(@project, @project_instance) unless deploy_allowed?
      return if params[:custom_deploy]

      deploy(@project_instance)
      redirect_to GitProviders::Url::PullMergeRequest.new(@project_instance, @project.integration_type).call
    end

    def create
      @project = find_project
      @project_instance = find_project_instance(@project)

      return redirect_to project_project_instance_path(@project, @project_instance) unless deploy_allowed?

      if @project_instance.update_branches(branches_params)
        deploy(@project_instance)
        redirect_to project_project_instance_path(@project, @project_instance)
      else
        @repositories = find_available_repositories
        render :show
      end
    end

    private

    def find_project(action: :create_instance?)
      authorize ProjectDomain.by_id(params[:project_id]), action, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      project.project_instance(id: params[:project_instance_id])
    end

    def find_available_repositories
      @project.project_record.repositories.active
    end

    def deploy_allowed?
      unless ProjectInstancePolicy.new(current_user, @project_instance).deploy_by_link?
        flash.notice = "Application already deployed"
        return false
      end

      unless @project.billing.can_create_instance?
        flash.notice = "Creation is not allowed. Please check project's payment"
        return false
      end

      true
    end

    def branches_params
      params.require(:project_instance).require(:configurations).permit!
    end

    def deploy(project_instance)
      Deployment::Processes::DeployNewInstance.new(@project, project_instance).call(current_user.user_reference)
    end
  end
end
