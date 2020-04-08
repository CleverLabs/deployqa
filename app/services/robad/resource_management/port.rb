# frozen_string_literal: true

module Robad
  module ResourceManagement
    class Port
      class << self
        def allocate
          rand(10_000..20_000)
        end
      end
    end
  end
end
