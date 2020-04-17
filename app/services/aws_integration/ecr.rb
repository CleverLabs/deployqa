# frozen_string_literal: true

module AwsIntegration
  class Ecr
    def initialize(project_name, project_id)
      @project_id = project_id
      @project_name = project_name
      @client = Aws::ECR::Client.new
      @safe_call = ::Utils::SafeCall.new(exceptions: [StandardError])
    end

    # rubocop:disable Metrics/LineLength
    def create_for(repo_name:)
      @safe_call.safely_with_result do
        name = Deployment::ConfigurationBuilders::NameBuilder.new.external_repo_name(@project_name, @project_id, repo_name)
        responce = @client.create_repository(repository_name: name, tags: [{ key: "CreatedFrom", value: self.class.name }])

        @client.put_lifecycle_policy(
          registry_id: responce.repository.registry_id,
          repository_name: responce.repository.repository_name,
          lifecycle_policy_text: "{\"rules\":[{\"rulePriority\":1,\"description\":\"Remove old images\",\"selection\":{\"tagStatus\":\"any\",\"countType\":\"sinceImagePushed\",\"countUnit\":\"days\",\"countNumber\":60},\"action\":{\"type\":\"expire\"}}]}"
        )
      end
    end
    # rubocop:enable Metrics/LineLength
  end
end
