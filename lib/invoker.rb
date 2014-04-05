$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

require "fileutils"
require "formatador"

require "ostruct"
require "uuid"
require "json"
require "rainbow"
require "rainbow/ext/string"

require "invoker/version"
require "invoker/logger"
require "invoker/daemon"
require "invoker/cli"
require "invoker/dns_cache"
require "invoker/ipc"
require "invoker/power/config"
require "invoker/power/port_finder"
require "invoker/power/setup"
require "invoker/power/powerup"
require "invoker/errors"
require "invoker/parsers/procfile"
require "invoker/parsers/config"
require "invoker/commander"
require "invoker/command_worker"
require "invoker/reactor"
require "invoker/event/manager"
require "invoker/process_printer"

module Invoker
  class << self
    attr_accessor :config, :tail_watchers, :commander
    attr_accessor :dns_cache

    def darwin?
      ruby_platform.downcase.include?("darwin")
    end

    def ruby_platform
      RUBY_PLATFORM
    end

    def load_invoker_config(file, port)
      @config = Invoker::Parsers::Config.new(file, port)
      @dns_cache = Invoker::DNSCache.new(@invoker_config)
      @tail_watchers = Invoker::CLI::TailWatcher.new
      @commander = Invoker::Commander.new
    end

    def close_socket(socket)
      socket.close
    rescue StandardError => error
      Invoker::Logger.puts "Error removing socket #{error}"
    end
  end

  def self.can_run_balancer?(throw_warning = true)
    return false unless darwin?
    return true if File.exist?(Invoker::Power::Config::CONFIG_LOCATION)

    if throw_warning
      Invoker::Logger.puts("Invoker has detected setup has not been run. Domain feature will not work without running setup command.".color(:red))
    end
    false
  end

  def self.daemonize=(daemonize)
    @daemonize = daemonize
  end

  def self.daemonize?
    @daemonize
  end

  def self.daemon
    @daemon ||= Invoker::Daemon.new
  end
end
