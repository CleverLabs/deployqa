# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class ShellCommand
      SUCCESS_EXIT_CODE = 0

      def initialize(heroku, app_name)
        @heroku = heroku
        @app_name = app_name
      end

      def execute(command, env)
        log, exit_code = fetch_dyno_result(command, env)

        return ReturnValue.error(errors: log) unless exit_code == SUCCESS_EXIT_CODE

        ReturnValue.ok(log)
      end

      private

      def fetch_dyno_result(command, env)
        log_url = one_off_dyno(command, env).fetch("attach_url")
        dyno_log_and_exit_code(command, log_url)
      end

      def dyno_log_and_exit_code(command, log_url)
        rendezvous_client = Rendezvous.new(input: StringIO.new, output: StringIO.new, url: log_url, activity_timeout: 15.minutes.to_i)
        rendezvous_client.start
        rendezvous_client.output.rewind
        logs = rendezvous_client.output.read.strip

        ["Log for '#{command}':\n#{logs.chop}", logs[-1].to_i]
      rescue StandardError
        ["Error capturing output for command '#{command}'", 1]
      end

      def one_off_dyno(command, env)
        @heroku.dyno.create(@app_name, command: "#{command}; echo $?", env: env, attach: true)
      end
    end
  end
end
