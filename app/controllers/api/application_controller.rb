# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include Pundit

    before_action -> { doorkeeper_authorize!(:internal_api) }

    rescue_from Exception, with: handle_api_exception

    private

    def handle_api_exception(exception)
      status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
      render json: { error: exception.message }, status: status_code
    end
  end
end
