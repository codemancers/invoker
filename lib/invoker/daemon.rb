require "daemons"

module Invoker
  class Daemon
    APP_NAME = 'invoker'
    DIR_MODE = :normal
    DIR = '/tmp'

    def self.start
      options = {
        app_name: APP_NAME,
        dir_mode: DIR_MODE,
        dir: DIR
      }
      Daemons.daemonize(options)
      Invoker::Logger.puts "Invoker running as a daemon"
    end

    def self.stop
      monitor = Daemons::Monitor.find(DIR, APP_NAME)
      if monitor
        monitor.stop
        Invoker::Logger.puts "Stopped Invoker daemon".color(:green)
      else
        Invoker::Logger.puts "Invoker daemon not running".color(:red)
      end
    end
  end
end
