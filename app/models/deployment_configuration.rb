class DeploymentConfiguration < ApplicationRecord
  belongs_to :project
  has_many :project_instances

  validates :name, presence: true
end
