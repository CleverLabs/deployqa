# frozen_string_literal: true

module ProjectInstances
  class BuildActionsController < ApplicationController
    def show
      @build_action = BuildAction.find(params[:id])
    end
  end
end
