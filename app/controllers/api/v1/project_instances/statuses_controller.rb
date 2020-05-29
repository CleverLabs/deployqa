# frozen_string_literal: true

module Api
  module V1
    module ProjectInstances
      class StatusesController < ::Api::ApplicationController
        def show
          render json: { success: "true" }
        end

        private

        def find_project_instance
          application_name = params[:project_instance_id].split(".")[1]
          ProjectInstanceDomain.by_sleep_url(application_name)
        end
      end
    end
  end
end
