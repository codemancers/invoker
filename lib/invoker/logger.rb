module Invoker
  class Logger
    LOGGER_FILE = File.open("/tmp/invoker.log", "a")
    def self.puts(message)
      return if ENV["INVOKER_TESTS"]
      $stdout.puts(message)
    end

    def self.log(message)
      LOGGER_FILE.write(message)
    end

    def self.print(message)
      return if ENV["INVOKER_TESTS"]
      $stdout.print(message)
    end
  end
end
