# frozen_string_literal: true

module AwsIntegration
  class Ecr
    def initialize(project_name)
      @project_name = project_name
      @client = Aws::ECR::Client.new
      @safe_call = ::ServerAccess::HerokuHelpers::SafeCall.new(exceptions: [StandardError])
    end

    def create_for(repo_name:)
      @safe_call.safely_with_result do
        @client.create_repository(repository_name: "deployqa-repo-#{@project_name}/#{repo_name}", tags: [{ key: "CreatedFrom", value: self.class.name }])
      end
    end
  end
end
