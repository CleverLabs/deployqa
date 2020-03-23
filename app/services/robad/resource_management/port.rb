# frozen_string_literal: true

module Robad
  module ResourceManagement
    class Port
      class << self
        def allocate
          rand(10000..20000)
        end
      end
    end
  end
end
