# frozen_string_literal: true

require "nomad_client"

module NomadIntegration
  class Create
    def initialize(configurations, state_machine)
      @configurations = configurations
      @state_machine = state_machine
      @logger = @state_machine.logger

      @name = configurations.first.application_name

      @db_name = SecureRandom.alphanumeric
      @db_user = SecureRandom.alphanumeric
      @db_password = SecureRandom.alphanumeric

      # TODO: assign, not rand
      @db_port = rand(10000..20000)

      @repo_addres = "#{ENV['AWS_ACCOUNT_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/deployqa-builds-testing"
      @container_addres = @repo_addres + ":latest"
    end

    def call
      data = Utils::Encryptor.new.encrypt(@configurations.to_json)
      Sidekiq::Client.push({ "class" => "Robad::Workers::Create", "queue" => "asd", "args" => [data] })

      @state_machine.start
      @state_machine.add_state(:create_server) { ReturnValue.ok }
      @state_machine.finalize
      # @state_machine.start
      # @state_machine.add_state(:create_server) do
      #   # git_clone_job
      #   # build_job
      #   instance_job
      #   # db_setup_job
      #   # clean_up_job
      #   ReturnValue.ok
      # end

      # @state_machine.finalize
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
                    image: "gcr.io/kaniko-project/executor:v0.16.0",
                    args: ["--dockerfile=/workspace/Dockerfile", "--context=/workspace", "--destination=#{@container_addres}", "--force", "--cache=true", "--cache-repo=#{@repo_addres}"],
                    mounts: [
                      { type: "bind", source: "/mnt/shared_volume/#{@name}", target: "/workspace", readonly: false },
                      { type: "bind", source: "/mnt/shared_volume/kaniko_cache", target: "/cache", readonly: false },
                      { type: "bind", source: "/home/ubuntu/client_configuration_files/.docker", target: "/kaniko/.docker", readonly: false }
                    ]
                  },
                  env: {
                    AWS_ACCESS_KEY_ID: ProjectAddonInfo.last.tokens["access_key_id"],
                    AWS_SECRET_ACCESS_KEY: ProjectAddonInfo.last.tokens["secret_access_key"]
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

    def wait_until_task_is_running(evaluation)
      allocation = Nomad.evaluation.allocations_for(evaluation.eval_id).last

      (1..10).each do |_|
        allocation = Nomad.allocation.read(allocation.id)
        return if allocation.task_states.all? do |_task_name, state|
          state.events.any? { |event| event.type == "Started" }
        end

        sleep 3
      end

      raise "Task not started"
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
      domain = "#{@name}.#{ENV['INSTANCE_EXPOSURE_DOMAIN']}"

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
                    image: @container_addres,
                    args: ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "80"],
                    port_map: [{ http: 80 }],
                  },
                  env: {
                    RAILS_LOG_TO_STDOUT: "true",
                    RAILS_ENV: "production",
                    SECRET_KEY_BASE: SecureRandom.hex,
                    RAILS_SERVE_STATIC_FILES: "true",
                    DATABASE_URL: "postgres://#{@db_user}:#{@db_password}@#{ENV['DB_EXPOSURE_IP']}:#{@db_port}/#{@db_name}"
                  },
                  services: [{ name: job_name, tags: ["global", "instance", "urlprefix-#{domain}/"], portlabel: "http", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
                  resources: { cpu: 300, memorymb: 300, networks: [{ mode: "none", mbits: 20, dynamicports: [{ label: "http" }] }] }
                },
                {
                  name: "database",
                  driver: "docker",
                  config: { image: "postgres", port_map: [{ db: 5432 }], args: ["postgres", "-c", "log_connections=true", "-c", "log_disconnections=true", "-c", "log_error_verbosity=VERBOSE"] },
                  env: { POSTGRES_PASSWORD: @db_password, POSTGRES_DB: @db_name, POSTGRES_USER: @db_user },
                  services: [{ name: job_name + "-db", tags: ["global", "instance_db", "urlprefix-#{ENV['DB_LB_LOCAL_IP']}:#{@db_port} proto=tcp"], portlabel: "db", checks: [{ name: "alive", type: "tcp", interval: 10000000000, timeout: 2000000000 }] }],
                  resources: { cpu: 100, memorymb: 100, networks: [{ mbits: 10, dynamicports: [{ label: "db" }] }] },
                }
              ]
            }
          ]
        }
      }
      wait_until_task_is_running(Nomad.job.create(job_specification))
    end

    def db_setup_job
      job_name = "db-setup-instance-" + @name
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
                  name: "db_setup",
                  driver: "docker",
                  config: {
                    image: @container_addres,
                    args: ["bundle", "exec", "rails", "db:schema:load"]
                  },
                  resources: { cpu: 3000, memorymb: 1024 },
                  env: {
                    RAILS_LOG_TO_STDOUT: "true",
                    RAILS_ENV: "production",
                    SECRET_KEY_BASE: SecureRandom.hex,
                    SAFETY_ASSURED: "true",
                    DATABASE_URL: "postgres://#{@db_user}:#{@db_password}@#{ENV['DB_EXPOSURE_IP']}:#{@db_port}/#{@db_name}"
                  }
                }
              ]
            }
          ]
        }
      }

      wait_until_build_is_done(Nomad.job.create(job_specification), task_name: "db_setup")
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
