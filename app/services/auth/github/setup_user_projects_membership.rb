# frozen_string_literal: true

module Auth
  module Github
    class AddUserToProjects
      def initialize(user)
        @user = user
      end

      def call
        Project.where(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: user_installations_ids).each do |project|
          ProjectUserRole.find_or_create_by(user: @user, project: project) do |role|
            role.role = ProjectUserRoleConstants::REGULAR_USER
          end
        end
      end

      private

      def user_installations_ids
        installations_hash = ::ProviderAPI::Github::UserClient.new(user_auth_token).find_user_installations.to_h
        ::Github::Events::UserInstallations.new(payload: installations_hash).installations.map(&:id)
      end

      def user_auth_token
        @user.user_references.where(auth_provider: OmniauthConstants::GITHUB).first.auth_info.token
      end
    end
  end
end
