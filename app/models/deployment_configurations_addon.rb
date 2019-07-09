# frozen_string_literal: true

class DeploymentConfigurationsAddon < ApplicationRecord
  belongs_to :deployment_configuration
  belongs_to :addon
end
