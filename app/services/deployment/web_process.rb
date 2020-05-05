# frozen_string_literal: true

module Deployment
  class WebProcess
    include ShallowAttributes

    attribute :name, String
    attribute :command, String
    attribute :docker_image, String
    attribute :dockerfile_path, String
    attribute :expose_port, Integer
    attribute :external_port, Integer
    attribute :external_exposure, String
    # attribute :number, Integer        # Will be added after ability to change it

    def to_procfile_command
      "#{name}: #{command}"
    end
  end
end
