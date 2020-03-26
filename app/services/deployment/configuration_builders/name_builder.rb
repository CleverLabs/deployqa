# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class NameBuilder
      def application_name(project_name, project_id, repo_name, instance_name)
        name = application_name_prefix(project_name, project_id) + "-#{repo_name}-#{instance_name}"
        Utils::NameSanitizer.sanitize_downcase(name)
      end

      def application_name_prefix(project_name, project_id)
        Utils::NameSanitizer.sanitize_downcase("#{project_name}-#{project_id}")
      end

      def external_project_name(project_name, project_id)
        "deployqa-project-#{project_name}-#{project_id}"
      end

      def external_repo_name(project_name, project_id, repo_name)
        name = "deployqa-repo-#{project_name}-#{project_id}-#{repo_name}"
        Utils::NameSanitizer.sanitize_downcase(name)
      end

      def external_resource_name(application_name)
        "deployqa-resource-#{application_name}"
      end

      def heroku_app_url(application_name)
        "https://#{application_name}.herokuapp.com"
      end

      def robad_app_url(application_name)
        "http://#{application_name}.#{ENV['INSTANCE_EXPOSURE_DOMAIN']}"
      end
    end
  end
end
