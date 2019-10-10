# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class DockerDeployConfigGenerator
      def initialize(web_processes)
        @web_processes = web_processes
      end

      def call
        @web_processes.each_with_object(build: { docker: { web: "Dockerfile" } }, run: {}) do |web_process, config|
          config[:run][web_process.name.to_sym] = web_process.name == "web" ? web_process.command : { command: [web_process.command], image: "web" }
        end.deep_stringify_keys.to_yaml
      end
    end
  end
end
