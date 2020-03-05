# frozen_string_literal: true

module Deployment
  class Addon
    include ShallowAttributes

    attribute :name, String
    attribute :integration_provider, String
    attribute :credentials_names, Array, of: String
    attribute :credentials, Hash
    attribute :addon_type, String
    attribute :specific_configuration, Hash
  end
end
