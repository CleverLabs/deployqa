# frozen_string_literal: true

module Plugins
  module Entry
    class OnProjectCreation
      def initialize(project_info)
        @project_info = project_info
      end

      def call
        aws_user = AwsIntegration::User.new(@project_info.uniq_name)

        access_key_hash = access_key_for_user(aws_user)
        create_plugin_info!(access_key_hash)

        aws_user.add_registry_access
        aws_user.add_s3_access(repo_prefix: s3_repos_prefix)

        ReturnValue.ok
      end

      private

      def access_key_for_user(aws_user)
        return { access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] } unless Rails.env.production?

        aws_user.create
        result = aws_user.create_access_key
        raise GeneralError, result.errors unless result.ok?

        result.object
      end

      def s3_repos_prefix
        name_builder = Deployment::ConfigurationBuilders::NameBuilder.new
        application_name = name_builder.application_project_prefix(@project_info.project_name, @project_info.project_id) + "*"
        name_builder.external_resource_name(application_name)
      end

      def create_plugin_info!(access_key_hash)
        ProjectAddonInfo.find_or_create_by!(
          project_id: @project_info.project_id,
          addon: Addon.find_by(name: "AWS S3")
        ).update!(
          tokens: access_key_hash
        )
      end
    end
  end
end
