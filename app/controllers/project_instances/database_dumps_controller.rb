# frozen_string_literal: true

module ProjectInstances
  class DatabaseDumpsController < ApplicationController
    def index
      @project = find_project
      @project_instance = find_project_instance(@project)
      @dumps_list = database_accessor(@project_instance).dumps_list
    end

    def show
      @project = find_project
      @project_instance = find_project_instance(@project)
      redirect_to database_accessor(@project_instance).link_to_dump(params[:id])
    end

    def create
      @project = find_project
      @project_instance = find_project_instance(@project)
      @dumps_list = database_accessor(@project_instance).start_db_dump

      redirect_to project_project_instance_database_dumps_path(@project, @project_instance)
    end

    def update
      @project = find_project
      @project_instance = find_project_instance(@project)
      @dumps_list = database_accessor(@project_instance).upload(params.require(:dump).fetch(:url))

      redirect_to project_project_instance_database_dumps_path(@project, @project_instance)
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      authorize project.project_instances.find(params[:project_instance_id]), :dumps?, policy_class: ProjectInstancePolicy
    end

    def database_accessor(project_instance)
      name = ProjectInstanceDomain.new(record: project_instance).configurations.first.application_name
      ServerAccess::HerokuDatabase.new(name: name)
    end
  end
end
