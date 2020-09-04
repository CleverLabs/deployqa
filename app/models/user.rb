# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  has_many :project_user_roles, dependent: :destroy
  has_many :projects, through: :project_user_roles
  has_many :user_references, dependent: :nullify # Do not need dependent destroy

  validates :system_role, presence: true

  enum system_role: UserConstants::SystemRoles::ALL
end
