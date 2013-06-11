$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

require "colored"
require_relative "invoker/version"
require_relative "invoker/runner"
require_relative "invoker/command_listener"
require_relative "invoker/errors"
require_relative "invoker/config"
require_relative "invoker/commander"
require_relative "invoker/command_worker"
require_relative "invoker/reactor"





