require "logger"

module App
  @@my_logger = Logger.new(STDOUT)

  def self.logger
    @@my_logger.tap { |l| l.level = Logger::DEBUG }
  end
end
