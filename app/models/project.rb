# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: :owner_id
  has_many :deployment_configurations
  has_many :project_instances

  validates :name, presence: true
end
