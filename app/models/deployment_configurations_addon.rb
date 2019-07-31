# frozen_string_literal: true

class DeploymentConfigurationsAddon < ApplicationRecord
  has_paper_trail

  belongs_to :deployment_configuration
  belongs_to :addon
end
