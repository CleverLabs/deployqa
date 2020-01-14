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
        ReturnValue.ok
      end

      @state_machine.finalize
    end

    private

    def build_job
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
                  driver: "raw_exec",
                  config: { command: "/bin/bash", args: ["/home/ubuntu/build.sh"] },
                }
              ]
            }
          ]
        }
      }

      Nomad.job.create(job_specification)
      job_name
    end

    def wait_until_build_is_done(job_name)
      while Nomad.job.read(job_name).status.in? ["pending", "running"]
        puts Nomad.job.read(job_name).status
        sleep 100
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
                  config: { image: "#{ENV['REGISTRY_ADDESS']}/deployqa-builds-testing:latest", args: ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "80"], port_map: [{ http: 80 }] },
                  env: { RAILS_LOG_TO_STDOUT: "true", RAILS_ENV: "production", SECRET_KEY_BASE: SecureRandom.hex, DATABASE_URL: "postgres://postgres:temp_pass@${NOMAD_ADDR_database_db}/postgres" },
                  services: [{ name: job_name, tags: ["global", "instance", "urlprefix-/#{@name}"], portlabel: "http", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
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
  end
end



