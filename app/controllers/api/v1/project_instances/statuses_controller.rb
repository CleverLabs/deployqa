# frozen_string_literal: true

module Api
  module V1
    module ProjectInstances
      class StatusesController < ::Api::ApplicationController
        def show
          project_instance = find_project_instance
          render json: { project_instance: { sleeping: project_instance.sleeping? } }
        end

        private

        def find_project_instance
          application_name = params[:project_instance_id].split(".").last
          ProjectInstanceDomain.by_sleep_url(application_name)
        end
      end
    end
  end
end
