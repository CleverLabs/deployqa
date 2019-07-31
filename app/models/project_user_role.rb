# frozen_string_literal: true

class ProjectUserRole < ApplicationRecord
  extend Enumerize
  has_paper_trail

  belongs_to :project
  belongs_to :user

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id }

  enumerize :role, in: ProjectUserRoleConstants::ROLES
end
