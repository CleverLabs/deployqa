# frozen_string_literal: true

module Deployment
  class BuildConfiguration
    include ShallowAttributes

    attribute :build_type, String
    attribute :private_gem_detected, "Boolean"
  end
end
