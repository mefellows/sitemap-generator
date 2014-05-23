require 'log4r'

module Logging

  def log
    @log ||= Logging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    include Log4r

    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = Logger.new classname.to_s.gsub(/[^a-zA-Z0-9]/, '.').downcase.gsub(/\.+/, '.')
      # logger = Logger.new classname.to_s.gsub(/\.+/, '.').downcase
      logger.outputters = Outputter.stdout
      logger
    end
  end
end