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

      def docker_repo_address(project_name, project_id, repo_name)
        name = external_repo_name(project_name, project_id, repo_name)
        "#{ENV['AWS_ACCOUNT_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/#{name}"
      end

      def docker_image(repo_address, build_id, process_name)
        "#{repo_address}:#{process_name}_build_#{build_id}"
      end

      def heroku_app_url(application_name)
        "https://#{application_name}.herokuapp.com"
      end

      def robad_app_url(application_name, process_name)
        "http://#{process_name}.#{application_name}.#{ENV['INSTANCE_EXPOSURE_DOMAIN']}"
      end

      def robad_app_url_ip_port(application_name, process_name)
        "#{ENV['DB_EXPOSURE_IP']}:#{Robad::ResourceManagement::Port.allocate(resource_info: { application_name: application_name, process_name: process_name })}"
      end
    end
  end
end
