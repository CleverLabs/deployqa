# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Deployment
  module ConfigurationBuilders
    class ByProject
      def initialize(project, build_id, docker_feature)
        @project = project
        @docker_feature = docker_feature
        @build_id = build_id
      end

      def call(instance_name, branches)
        active_repositories = @project.repositories.active.map { |repository| [repository, build_name(repository, instance_name)] }
        exposures = Deployment::ConfigurationBuilders::Helpers::ExposuresBuilder.new(active_repositories, @docker_feature).call
        active_repositories.map do |active_repository, name|
          Deployment::Configuration.new(configuration_hash(active_repository, name, branches, exposures))
        end
      end

      private

      def configuration_hash(repository, name, branches, exposures)
        {
          application_name: name,
          repository_id: repository.id,
          heroku_buildpacks: repository.heroku_buildpacks,
          seeds_command: repository.seeds_command,
          migration_command: repository.migration_command,
          schema_load_command: repository.schema_load_command,
          application_url: application_url(name)
        }.merge(build_dependencies(repository, branches, exposures))
          .merge(build_env_with_addons(repository, name, exposures))
      end

      def build_dependencies(repository, branches, exposures)
        {
          web_processes: build_web_processes(repository, repository.web_processes.to_a, exposures),
          repo_configuration: build_repo_configuration_by_project(repository, branches),
          build_configuration: build_build_configuration(repository)
        }
      end

      def build_env_with_addons(repository, name, exposures)
        addons = build_addons(repository, name)
        env = build_env_variables(repository, exposures)
        addons.each { |addon| env = env.merge(addon.fetch("credentials", {})) }
        Deployment::Helpers::EnvAliasing.new(env).modify!

        { env_variables: env, addons: addons }
      end

      def build_name(repository, instance_name)
        Deployment::ConfigurationBuilders::NameBuilder.new.application_name(@project.name, @project.id, repository.name, instance_name)
      end

      def build_env_variables(repository, exposures)
        Deployment::ConfigurationBuilders::EnvVariablesBuilder.new(repository, @project, exposures, @docker_feature).call
      end

      def build_addons(repository, name)
        repository.addons.to_a.map do |addon|
          Deployment::ConfigurationBuilders::AddonsBuilder.new(repository, addon, name, @docker_feature).call
        end
      end

      def build_web_processes(repository, web_processes, exposures)
        web_processes.map do |web_process|
          attributes = web_process.attributes.slice(*Deployment::WebProcess.attributes.map(&:to_s))
          image, dockerfile = docker_info(web_process, repository)
          attributes.merge(
            docker_image: image,
            dockerfile_path: dockerfile,
            expose_port: web_process.expose_port.presence,
            external_exposure: exposures[repository.path + "_" + web_process.name]
          )
        end
      end

      def docker_info(web_process, repository)
        if web_process.expose_port
          process_name = web_process.name
          dockerfile = web_process.dockerfile.presence || "Dockerfile"
        else
          process_name = "web"
          dockerfile = "Dockerfile"
        end
        _, image = docker_addresses(repository, process_name)

        [image, dockerfile]
      end

      def application_url(application_name)
        if @docker_feature.call
          Deployment::ConfigurationBuilders::NameBuilder.new.robad_app_url(application_name, "web")
        else
          Deployment::ConfigurationBuilders::NameBuilder.new.heroku_app_url(application_name)
        end
      end

      def build_repo_configuration_by_project(repository, branches)
        Deployment::RepoConfiguration.new(
          repo_path: repository.path,
          git_reference: branches.fetch(repository.name, "master"),
          project_integration_id: Deployment::ConfigurationBuilders::IntegrationIdBuilder.new(repository).call,
          project_integration_type: @project.integration_type
        )
      end

      def build_build_configuration(repository)
        repo_address, image = docker_addresses(repository)
        private_gem_detected = @project.repositories.any? { |configuration| configuration.build_type == RepositoryConstants::PRIVATE_GEM }

        Deployment::BuildConfiguration.new(
          build_type: repository.build_type,
          env_variables: env_variables_for_build(repository, private_gem_detected),
          private_gem_detected: private_gem_detected,
          docker_repo_address: repo_address,
          docker_image: image
        )
      end

      def docker_addresses(repository, process_name = nil)
        repo_address = Deployment::ConfigurationBuilders::NameBuilder.new.docker_repo_address(@project.name, @project.id, repository.name)
        image = Deployment::ConfigurationBuilders::NameBuilder.new.docker_image(repo_address, @build_id, process_name)

        [repo_address, image]
      end

      def env_variables_for_build(repository, private_gem_detected)
        env = repository.build_env_variables.merge("DEPLOYQA_DEPLOYMENT" => "1")
        return env unless private_gem_detected && @project.integration_type == ProjectsConstants::Providers::GITHUB

        env.merge("BUNDLE_GITHUB__COM" => ::ProviderApi::Github::AppClient.new(@project.integration_id).token_for_gem_bundle)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
