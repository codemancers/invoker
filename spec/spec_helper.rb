require "pry"
require "simplecov"
require 'fakefs/spec_helpers'

SimpleCov.start do
  add_filter "/spec/"
end


require "invoker"
require "invoker/power/power"
MM = Invoker::IPC::Message

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.mock_framework = :mocha
  config.include FakeFS::SpecHelpers, fakefs: true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

ENV["INVOKER_TESTS"] = "true"

def invoker_commander
  Invoker.commander ||= mock
end

def invoker_dns_cache
  Invoker.dns_cache ||= mock
end

def inv_conf_dir
  File.join(ENV['HOME'], '.invoker')
end

def inv_conf_file
  File.join(inv_conf_dir, 'config')
end
