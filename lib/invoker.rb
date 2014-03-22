$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

require "fileutils"
require "formatador"
require 'rubydns'
require 'em-proxy'
require 'http-parser'
require "ostruct"
require "uuid"
require "highline"
require "yajl"
require "invoker/version"
require "invoker/logger"
require "invoker/cli"
require "invoker/ipc"
require "invoker/power"
require "invoker/errors"
require "invoker/parsers/procfile"
require "invoker/parsers/config"
require "invoker/parsers/option_parser"
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

  def self.can_run_balancer?(throw_warning = true)
    return false unless darwin?
    return true if File.exists?(Invoker::Power::Config::CONFIG_LOCATION)

    if throw_warning
      Invoker::Logger.puts("Invoker has detected setup has not been run. Domain feature will not work without running setup command.".color(:red))
    end
    false
  end
end
