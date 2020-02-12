# frozen_string_literal: true

module Plugins
  module Adapters
    class NewInstance
      include ShallowAttributes

      attribute :application_name, String
    end
  end
end
