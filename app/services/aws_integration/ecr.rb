# frozen_string_literal: true

module AwsIntegration
  class Ecr
    def initialize(project_name, project_id)
      @project_id = project_id
      @project_name = project_name
      @client = Aws::ECR::Client.new
      @safe_call = ::ServerAccess::HerokuHelpers::SafeCall.new(exceptions: [StandardError])
    end

    def create_for(repo_name:)
      @safe_call.safely_with_result do
        name = Deployment::ConfigurationBuilders::NameBuilder.new.external_repo_name(@project_name, @project_id, @repo_name)
        @client.create_repository(repository_name: name, tags: [{ key: "CreatedFrom", value: self.class.name }])
      end
    end
  end
end
