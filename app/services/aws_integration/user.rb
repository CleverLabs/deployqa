# frozen_string_literal: true

module AwsIntegration
  class User
    def initialize(project_name)
      @client = Aws::IAM::Client.new
      @project_name = project_name
      @safe_call = Utils::SafeCall.new(exceptions: [StandardError], max_number_of_tries: 1)
    end

    def create
      @safe_call.safely_with_result do
        @client.get_user(user_name: @project_name)
      rescue Aws::IAM::Errors::NoSuchEntity
        @client.create_user(user_name: @project_name)
      end
    end

    def create_access_key
      @safe_call.safely_with_result do
        result = @client.create_access_key(user_name: @project_name)
        result.to_h.fetch(:access_key).slice(:access_key_id, :secret_access_key)
      end
    end

    def add_registry_access
      @safe_call.safely_with_result do
        resource = "arn:aws:ecr:#{ENV['AWS_REGION']}:#{ENV['AWS_ACCOUNT_ID']}:repository/deployqa-repo-#{@project_name}"

        @client.put_user_policy(
          policy_document: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ecr:*\",\"Resource\":\"#{resource}\"}]}",
          policy_name: "AccessToPrivateECRPolicy",
          user_name: @project_name
        )
      end
    end

    def add_s3_access(repo_prefix:)
      @safe_call.safely_with_result do
        resource = "arn:aws:s3:::#{repo_prefix}"

        @client.put_user_policy(
          policy_document: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"#{resource}\"}]}",
          policy_name: "AccessToS3ForInstancesPolicy",
          user_name: @project_name
        )
      end
    end
  end
end
