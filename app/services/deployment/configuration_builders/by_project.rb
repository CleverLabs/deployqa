# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class ByProject
      def initialize(project)
        @project = project
      end

      def call(instance_name, branches)
        active_repositories = @project.repositories.active.map { |repository| [repository, build_name(repository, instance_name)] }
        active_repositories.map do |active_repository, name|
          Deployment::Configuration.new(configuration_hash(active_repository, name, branches, active_repositories))
        end
      end

      private

      def configuration_hash(repository, name, branches, active_repositories)
        {
          application_name: name,
          repository_id: repository.id,
          heroku_buildpacks: repository.heroku_buildpacks,
          seeds_command: repository.seeds_command,
          application_url: heroku_url(name)
        }.merge(build_dependencies(repository, branches))
         .merge(build_env_with_addons(repository, name, active_repositories))
      end

      def build_dependencies(repository, branches)
        {
          web_processes: build_web_processes(repository),
          repo_configuration: build_repo_configuration_by_project(repository, branches),
          build_configuration: build_build_configuration(repository)
        }
      end

      def build_env_with_addons(repository, name, active_repositories)
        addons = build_addons(repository)
        env = build_env_variables(repository, name, active_repositories)
        addons.each { |addon| env = env.merge(addon.fetch("credentials")) }

        { env_variables: env, addons: addons }
      end

      def build_name(repository, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.application_name(@project.name, @project.id, repository.name, instance_name)
      end

      def build_env_variables(repository, name, active_repositories)
        Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(repository, @project, name, active_repositories).call
      end

      def build_addons(repository)
        repository.addons.to_a.map do |addon|
          Deployment::ConfigurationBuilders::AddonsBuilder.new(repository, addon).call
        end
      end

      def build_web_processes(repository)
        repository.web_processes.to_a.map { |web_process| web_process.attributes.slice(*Deployment::WebProcess.attributes.map(&:to_s)) }
      end

      def heroku_url(application_name)
        "https://#{application_name}.herokuapp.com"
      end

      def build_repo_configuration_by_project(repository, branches)
        Deployment::RepoConfiguration.new(
          repo_path: repository.path,
          git_reference: branches.fetch(repository.name, "master"),
          project_integration_id: @project.integration_id,
          project_integration_type: @project.integration_type
        )
      end

      def build_build_configuration(repository)
        Deployment::BuildConfiguration.new(
          build_type: repository.build_type,
          env_variables: temporary_env_variables(repository),
          private_gem_detected: @project.repositories.any? { |configuration| configuration.build_type == RepositoryConstants::PRIVATE_GEM },
          docker_repo_address: docker_repo_address(repository)
        )
      end

      def docker_repo_address(repository)
        name = Deployment::ConfigurationBuilders::NameBuilder.new.external_repo_name(@project.name, @project.id, repository.name)
        "#{ENV['AWS_ACCOUNT_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/#{name}"
      end

      def temporary_env_variables(repository)
        repository.build_env_variables.merge("BUNDLE_GITHUB__COM" => ::ProviderAPI::Github::AppClient.new(@project.integration_id).token_for_gem_bundle)
      end
    end
  end
end
