$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

module Necro
  VERSION = "0.0.1"
end

require "pry"
require "colored"
require_relative "necro/runner"
require_relative "necro/master"
require_relative "necro/errors"
require_relative "necro/config"
require_relative "necro/commander"
require_relative "necro/command_worker"
require_relative "necro/reactor"





