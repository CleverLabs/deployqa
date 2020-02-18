# frozen_string_literal: true

module Plugins
  module Adapters
    class NewRepo
      include ShallowAttributes

      attribute :project_name, String
      attribute :project_id, Integer
      attribute :repo_name, String

      def self.build(project_record, repo_name)
        new(
          project_name: project_record.name,
          project_id: project_record.id,
          repo_name: repo_name
        )
      end

      def project_uniq_name
        @_uniq_name ||= Deployment::ConfigurationBuilders::NameBuilder.new.external_project_name(project_name, project_id)
      end
    end
  end
end
