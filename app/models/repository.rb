# frozen_string_literal: true

class Repository < ApplicationRecord
  has_paper_trail

  belongs_to :project, required: true
  has_many :repositories_addons, dependent: :destroy
  has_many :addons, through: :repositories_addons
  has_many :web_processes, inverse_of: :repository, dependent: :destroy
  has_one :repository_setting, dependent: :destroy

  accepts_nested_attributes_for :web_processes, allow_destroy: true

  validates :name, :path, :status, :integration_id, :integration_type, presence: true
  validate :validate_github_gem

  enum status: RepositoryConstants::STATUSES
  enum integration_type: ProjectsConstants::Providers::ALL
  enum build_type: RepositoryConstants::BUILD_TYPES

  def validate_github_gem
    return if build_type != RepositoryConstants::PRIVATE_GEM

    errors.add(:build_type, "Private gem is only available in GitHub") if integration_type != ProjectsConstants::Providers::GITHUB
    errors.add(:build_type, "Private gem can only have 'inactive' status") if status != RepositoryConstants::INACTIVE
  end
end
