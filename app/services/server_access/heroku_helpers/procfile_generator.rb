# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class ProcfileGenerator
      def initialize(web_processes)
        @web_processes = web_processes
      end

      def call
        @web_processes.map(&:to_procfile_command).join("\n")
      end
    end
  end
end
