# frozen_string_literal: true

class DeployqaLogger
  def initialize(config)
    @config = config
  end

  def setup
    if ENV["RAILS_LOG_TO_STDOUT"].present?
      stdout_config
    else
      logstash_config
    end
  end

  private

  attr_reader :config

  def logstash_config
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Logstash.new
    config.lograge.logger = logstash_logger
  end

  def stdout_config
    config.log_formatter = ::Logger::Formatter.new
    config.logger = stdout_logger
  end

  def logstash_logger
    return LogStashLogger.new(type: :syslog) if ENV["LOGSTASH_HOST"].blank?

    LogStashLogger.new(type: :udp, host: ENV["LOGSTASH_HOST"], port: ENV.fetch("LOGSTASH_PORT", 5228))
  end

  def stdout_logger
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    ActiveSupport::TaggedLogging.new(logger)
  end
end
