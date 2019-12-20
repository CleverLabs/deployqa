# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class RevokeAuth
        def initialize(body)
          @wrapped_body = Github::Events::Authorization.new(payload: body)
        end

        def call
          user_reference.user.project_user_roles.destroy_all
          ReturnValue.ok
        end

        private

        def user_reference
          @_user_reference ||= ::UserReference.find_by(auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: @wrapped_body.id)
        end
      end
    end
  end
end
