# frozen_string_literal: true

require "nomad_client"

module NomadIntegration
  class Create
    def initialize(configurations, state_machine)
      @configurations = configurations
      @state_machine = state_machine
      @logger = @state_machine.logger

      @name = configurations.first.application_name
    end

    def call
      @state_machine.start
      @state_machine.add_state(:create_server) do
        # git_clone_job
        # build_job
        instance_job
        # clean_up_job
        ReturnValue.ok
      end

      @state_machine.finalize
    end

    private

    def git_clone_job
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
                  name: "clone",
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

      wait_until_build_is_done(Nomad.job.create(job_specification), task_name: "clone")
    end

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
                  name: "build",
                  driver: "docker",
                  config: {
                    image: "gcr.io/kaniko-project/executor:latest",
                    args: ["--dockerfile=/workspace/Dockerfile", "--context=/workspace", "--destination=#{ENV['REGISTRY_ADDESS']}/deployqa-builds-testing:latest", "--force", "--cache=true"],
                    # args: ["--dockerfile=/workspace/Dockerfile", "--context=/workspace", "--destination=#{ENV['REGISTRY_ADDESS']}/deployqa-builds-testing:latest", "--force"],
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

      wait_until_build_is_done(Nomad.job.create(job_specification), task_name: "build")
    end

    def wait_until_build_is_done(evaluation, task_name:, time_to_wait: 2)
      sleep 3
      allocation = Nomad.evaluation.allocations_for(evaluation.eval_id).last
      err_offset = 0
      out_offset = 0

      while allocation.client_status.in? ["pending", "running"]
        sleep time_to_wait

        allocation = Nomad.allocation.read(allocation.id)

        err_offset += read_logs(allocation.id, task_name, "stderr", err_offset)
        out_offset += read_logs(allocation.id, task_name, "stdout", out_offset)
      end
    end

    def read_logs(allocation, task_name, type, offset)
      logs = Nomad.client.get("/v1/client/fs/logs/#{allocation}", task: task_name, type: type, plain: true, offset: offset)
      logs.split(/\n|\r/).each { |message| @logger.info(uncolorize(message), context: "#{type}-#{task_name}") }
      logs.size
    end

    def uncolorize(string)
      string.gsub(/\e\[(\d+)(;\d+)*m/, "")
    end


    def instance_job
      domain = "#{@name}.#{ENV["INSTANCE_EXPOSURE_DOMAIN"]}"
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
                  env: {
                    RAILS_LOG_TO_STDOUT: "true",
                    RAILS_ENV: "production",
                    SECRET_KEY_BASE: SecureRandom.hex,
                    DATABASE_URL: "postgres://postgres:temp_pass@#{domain}:5432"
                    # DATABASE_URL: "postgres://postgres:temp_pass@${NOMAD_ADDR_database_db}/postgres"
                  },
                  services: [{ name: job_name, tags: ["global", "instance", "urlprefix-#{domain}/"], portlabel: "http", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
                  resources: { cpu: 300, memorymb: 300, networks: [{ mode: "none", mbits: 20, dynamicports: [{ label: "http" }] }] }
                },
                {
                  name: "database",
                  driver: "docker",
                  config: { image: "postgres", port_map: [{ db: 5432 }], args: ["postgres", "-c", "log_connections=true", "-c", "log_disconnections=true", "-c", "log_error_verbosity=VERBOSE"] },
                  env: { POSTGRES_PASSWORD: "temp_pass" },
                  services: [{ name: job_name + "-db", tags: ["global", "instance_db", "urlprefix-#{domain}:5432 proto=tcp"], portlabel: "db", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
                  resources: { cpu: 100, memorymb: 100, networks: [{ mbits: 10, dynamicports: [{ label: "db" }] }] },
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
