# frozen_string_literal: true

module Deployment
  module Processes
    class CreateManualProjectInstance
      def initialize(project, user_reference)
        @project = project
        @user_reference = user_reference
        @features_accessor = Features::Accessor.new
      end

      def call(project_instance_name:, branches:, deploy_via_robad:)
        creation_result = create_project_instance(project_instance_name, branches)
        return creation_result unless creation_result.ok?

        deploy_instance(creation_result.object, deploy_via_robad)
        creation_result
      end

      private

      def create_project_instance(project_instance_name, branches)
        ProjectInstanceDomain.create(
          project_id: @project.id,
          name: project_instance_name,
          deployment_status: ProjectInstanceConstants::SCHEDULED,
          branches: branches
        )
      end

      def deploy_instance(instance, deploy_via_robad)
        build_action = instance.create_action!(author: @user_reference, action: BuildActionConstants::CREATE_INSTANCE)

        if deploy_via_robad
          @features_accessor.perform_docker_deploy!(instance)
          Robad::Executor.new(build_action).call(instance.deployment_configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, instance.deployment_configurations.map(&:to_h), build_action)
        end
      end
    end
  end
end
