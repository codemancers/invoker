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
  def self.darwin?
    ruby_platform.downcase.include?("darwin")
  end

  def self.ruby_platform
    RUBY_PLATFORM
  end

  def self.load_invoker_config(file, port)
    @invoker_config = Invoker::Parsers::Config.new(file, port)
    @dns_cache = Invoker::DNSCache.new(@invoker_config)
    @tail_watchers = Invoker::CLI::TailWatcher.new
  end

  def self.config
    @invoker_config
  end

  def self.tail_watchers
    @tail_watchers
  end

  def self.commander
    @invoker_commander ||= Invoker::Commander.new
  end

  def self.dns_cache
    @dns_cache
  end

  def self.can_run_balancer?(throw_warning = true)
    return false unless darwin?
    return true if File.exists?(Invoker::Power::Config::CONFIG_LOCATION)

    if throw_warning
      Invoker::Logger.puts("Invoker has detected setup has not been run. Domain feature will not work without running setup command.".color(:red))
    end
    false
  end
end
