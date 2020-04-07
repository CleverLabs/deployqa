# frozen_string_literal: true

module Deployment
  class BuildConfiguration
    include ShallowAttributes

    attribute :build_type, String
    attribute :private_gem_detected, "Boolean"
    attribute :env_variables, Hash
    attribute :docker_repo_address, String
    attribute :docker_image, String
  end
end
