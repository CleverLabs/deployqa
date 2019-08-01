# frozen_string_literal: true

module Deployment
  class Addon
    include ShallowAttributes

    attribute :name, String
    attribute :integration_provider, String
  end
end
