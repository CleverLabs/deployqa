# frozen_string_literal: true

class User < ApplicationRecord
  has_many :repos
  has_many :project_user_roles
  has_many :projects, through: :project_user_roles

  validates :system_role, presence: true

  enum system_role: UserConstants::SystemRoles::ALL
end
