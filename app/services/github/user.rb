# frozen_string_literal: true

module Github
  class User
    def initialize(auth_info_presenter)
      @auth_info_presenter = auth_info_presenter
    end

    def identify
      user = ::User.find_or_create_by!(user_uniq_id)
      user.update(token: @auth_info_presenter.token, full_name: @auth_info_presenter.full_name)
      create_or_update_auth_info(user)
      update_user_roles_for_projects(user)
      user
    end

    private

    def create_or_update_auth_info(user)
      auth_info = AuthInfo.find_or_initialize_by(user: user)
      auth_info.data = @auth_info_presenter.raw_info
      auth_info.save!
    end

    def user_uniq_id
      { auth_provider: OmniauthConstants::GITHUB, auth_uid: @auth_info_presenter.uid }
    end

    def update_user_roles_for_projects(user)
      installation_ids = Github::Events::UserInstallations.new(payload: ::ProviderAPI::Github::UserClient.new(user.token).find_user_installations.to_h).installations.map(&:id)

      Project.where(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: installation_ids).each do |project|
        ProjectUserRole.find_or_create_by(user: user, project: project) do |role|
          role.role = ProjectUserRoleConstants::REGULAR_USER
        end
      end
    end
  end
end
