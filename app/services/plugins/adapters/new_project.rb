# frozen_string_literal: true

module Plugins
  module Adapters
    class NewProject
      include ShallowAttributes

      attribute :project_name, String
      attribute :project_id, Integer

      def self.build(project_record)
        new(
          project_name: project_record.name,
          project_id: project_record.id
        )
      end

      def uniq_name
        @_uniq_name ||= Deployment::ConfigurationBuilders::NameBuilder.new.external_project_name(project_name, project_id)
      end
    end
  end
end
