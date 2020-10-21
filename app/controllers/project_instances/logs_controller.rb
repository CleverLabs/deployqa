# frozen_string_literal: true

module ProjectInstances
  class LogsController < ApplicationController
    def show
      @project = find_project
      @project_instance = find_project_instance(@project)
      @references = find_nomad_references
      @selected_reference = find_nomad_reference(@references)
      @out_logs = fetch_logs(@selected_reference, "stdout")
      @err_logs = fetch_logs(@selected_reference, "stderr")
      @project_instance_policy = ProjectInstancePolicy.new(current_user, @project_instance)
    end

    private

    def find_project
      authorize ProjectDomain.by_id(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      authorize project.project_instance(id: params[:project_instance_id]), :logs?, policy_class: ProjectInstancePolicy
    end

    def fetch_logs(nomad_reference, type)
      ProviderApi::Nomad::Client.new.tail_logs(nomad_reference.allocation_id, nomad_reference.process_name, type)
    end

    def find_nomad_references
      processes = @project_instance.configurations.map do |configuration|
        configuration.web_processes.map { |web_process| web_process["name"] }
      end.flatten

      NomadReference.where(project_instance_id: @project_instance.id, process_name: processes)
    end

    def find_nomad_reference(references)
      application_name, process_name = log_params
      references.find { |reference| reference.process_name == process_name && reference.application_name == application_name }
    end

    def log_params
      return [params[:application_name], params[:process_name]] if params[:application_name] && params[:process_name]

      configuration = @project_instance.configurations.first
      [configuration.application_name, configuration.web_processes.first["name"]]
    end
  end
end
