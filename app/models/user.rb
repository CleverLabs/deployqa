# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  has_many :project_user_roles, dependent: :destroy
  has_many :projects, through: :project_user_roles
  has_many :auth_infos, dependent: :destroy
  has_one :github_auth_info, -> { where(provider: OmniauthConstants::GITHUB) }, class_name: "AuthInfo"
  has_one :gitlab_auth_info, -> { where(provider: OmniauthConstants::GITLAB) }, class_name: "AuthInfo"

  validates :system_role, presence: true

  enum system_role: UserConstants::SystemRoles::ALL
end
