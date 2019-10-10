# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class DeleteProject
        def initialize(body)
          @body = body
        end

        def call
          ReturnValue.new(status: :no_action)
        end
      end
    end
  end
end
