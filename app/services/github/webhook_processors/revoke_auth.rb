# frozen_string_literal: true

module Github
  module WebhookProcessors
    class RevokeAuth
      def initialize(body)
        @wrapped_body = Github::Events::Authorization.new(payload: body)
      end

      def call
        user = User.find_by(auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: @wrapped_body.id)
        user.project_user_roles.destroy_all
      end
    end
  end
end
