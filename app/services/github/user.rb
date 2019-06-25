# frozen_string_literal: true

module Github
  class User
    TOKEN_PATH = %w[credentials token].freeze
    NAME_PATH = %w[info name].freeze
    RAW_INFO_PATH = %w[extra raw_info].freeze

    def initialize(omniauth_user)
      @omniauth_user = omniauth_user
    end

    def identify
      ::User.find_or_create_by!(user_uniq_id).tap do |user|
        user.update(token: token, full_name: full_name)
        update_user_roles_for_projects(user)
        GithubEntity.ensure_info_exists(user, raw_info)
      end
    end

    private

    def full_name
      @omniauth_user.dig(*NAME_PATH)
    end

    def token
      @omniauth_user.dig(*TOKEN_PATH)
    end

    def raw_info
      @omniauth_user.dig(*RAW_INFO_PATH)
    end

    def user_uniq_id
      { auth_provider: ProjectsConstants::Providers::GITHUB, auth_uid: Integer(@omniauth_user["uid"]) }
    end

    def update_user_roles_for_projects(user)
      installation_ids = Github::Events::UserInstallations.new(payload: GithubUserClient.new(user.token).find_user_installations.to_h).installations.map(&:id)

      Project.where(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: installation_ids).each do |project|
        ProjectUserRole.find_or_create_by(user: user, project: project) do |role|
          role.role = ProjectUserRoleConstants::REGULAR_USER
        end
      end
    end
  end
end
