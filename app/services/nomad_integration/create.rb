# frozen_string_literal: true

require "nomad"

module NomadIntegration
  class Create
    def initialize(configurations, state_machine)
      @configurations = configurations
      @state_machine = state_machine

      @name = configurations.first.application_name
    end

    def call
      @state_machine.start
      @state_machine.add_state(:create_server) do
        job_name = build_job
        wait_until_build_is_done(job_name)
        instance_job
        clean_up_job
        ReturnValue.ok
      end

      @state_machine.finalize
    end

    private

    def build_job
      job_name = "git_clone_" + @name
      job_specification = {
        job: {
          name: job_name,
          id: job_name,
          type: "batch",
          datacenters: ["dc1"],
          taskgroups: [
            {
              name: job_name,
              count: 1,
              tasks: [
                {
                  name: job_name,
                  driver: "raw_exec",
                  config: { command: "/bin/bash", args: [
                    "-c",
                    "git clone https://github.com/CleverLabs/deployqa.git /mnt/shared_volume/#{@name}",
                  ]},
                }
              ]
            }
          ]
        }
      }

      Nomad.job.create(job_specification)

      wait_until_build_is_done(job_name, time_to_wait: 3)

      job_name = "docker_build_" + @name
      job_specification = {
        job: {
          name: job_name,
          id: job_name,
          type: "batch",
          datacenters: ["dc1"],
          taskgroups: [
            {
              name: job_name,
              count: 1,
              tasks: [
                {
                  name: job_name,
                  driver: "docker",
                  config: {
                    image: "gcr.io/kaniko-project/executor:latest",
                    args: ["--dockerfile=/workspace/Dockerfile", "--context=/workspace", "--destination=#{ENV['REGISTRY_ADDESS']}/deployqa-builds-testing:latest", "--force", "--cache=true"],
                    mounts: [
                      { type: "bind", source: "/mnt/shared_volume/#{@name}", target: "/workspace", readonly: false },
                      { type: "bind", source: "/mnt/shared_volume/kaniko_cache", target: "/cache", readonly: false }
                    ]
                  },
                  resources: { cpu: 3000, memorymb: 1024 }
                }
              ]
            }
          ]
        }
      }

      Nomad.job.create(job_specification)
      job_name
    end

    def wait_until_build_is_done(job_name, time_to_wait: 3)
      while Nomad.job.read(job_name).status.in? ["pending", "running"]
        puts Nomad.job.read(job_name).status
        sleep time_to_wait
      end
    end

    def instance_job
      job_name = "instance-" + @name
      job_specification = {
        job: {
          name: job_name,
          id: job_name,
          type: "service",
          datacenters: ["dc1"],
          taskgroups: [
            {
              name: job_name,
              count: 1,
              tasks: [
                {
                  name: "web",
                  driver: "docker",
                  config: {
                    image: "#{ENV['REGISTRY_ADDESS']}/deployqa-builds-testing:latest",
                    args: ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "80"],
                    port_map: [{ http: 80 }],
                  },
                  env: { RAILS_LOG_TO_STDOUT: "true", RAILS_ENV: "production", SECRET_KEY_BASE: SecureRandom.hex, DATABASE_URL: "postgres://postgres:temp_pass@${NOMAD_ADDR_database_db}/postgres" },
                  services: [{ name: job_name, tags: ["global", "instance", "urlprefix-#{@name}.#{ENV["INSTANCE_EXPOSURE_DOMAIN"]}/"], portlabel: "http", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
                  resources: { cpu: 1000, memorymb: 1024, networks: [{ mbits: 20, dynamicports: [{ label: "http" }] }] }
                },
                {
                  name: "database",
                  driver: "docker",
                  config: { image: "postgres", port_map: [{ db: 5432 }] },
                  env: { POSTGRES_PASSWORD: "temp_pass" },
                  resources: { cpu: 250, memorymb: 100, networks: [{ mbits: 20, dynamicports: [{ label: "db" }] }] },
                }
              ]
            }
          ]
        }
      }
      Nomad.job.create(job_specification)
    end

    def clean_up_job
      job_name = "clean_up_" + @name
      job_specification = {
        job: {
          name: job_name,
          id: job_name,
          type: "batch",
          datacenters: ["dc1"],
          taskgroups: [
            {
              name: job_name,
              count: 1,
              tasks: [
                {
                  name: job_name,
                  driver: "raw_exec",
                  config: { command: "/bin/bash", args: [
                    "-c",
                    "rm -rf /mnt/shared_volume/#{@name}",
                  ]},
                }
              ]
            }
          ]
        }
      }

      Nomad.job.create(job_specification)
    end
  end
end
