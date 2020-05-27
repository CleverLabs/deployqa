# frozen_string_literal: true

module Api
  module V1
    module ProjectInstances
      class WakeUpsController < ::Api::ApplicationController
        def create
          project = find_project
          render json: { asd: "asd" }
        end

        private

        def find_project
          ProjectDomain.by_id(params[:project_id])
        end
      end
    end
  end
end
