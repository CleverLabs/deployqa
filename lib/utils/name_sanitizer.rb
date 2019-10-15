# frozen_string_literal: true

module Utils
  class NameSanitizer
    def self.sanitize_downcase(name)
      name.gsub(/([^\w]|_)/, "-").downcase
    end

    def self.sanitize_upcase(name)
      name.gsub(/([^\w]|_)/, "_").upcase
    end
  end
end
