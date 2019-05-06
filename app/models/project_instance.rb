# frozen_string_literal: true

class ProjectInstance < ApplicationRecord
  belongs_to :project
  has_many :build_actions

  validates :deployment_status, :git_reference, presence: true

  enum deployment_status: %i[scheduled running success failure canceled]
end
