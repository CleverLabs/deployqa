# frozen_string_literal: true

module Deployment
  class RepoConfiguration
    include ShallowAttributes

    attribute :repo_path, String
    attribute :git_reference, String
    attribute :project_integration_id, String
    attribute :project_integration_type, String
  end
end
