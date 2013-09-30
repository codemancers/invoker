module Invoker
  class Logger
    def self.puts(message)
      return if ENV["INVOKER_TESTS"]
      $stdout.puts(message)
    end

    def self.print(message)
      return if ENV["INVOKER_TESTS"]
      $stdout.print(message)
    end
  end
end
