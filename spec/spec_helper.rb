require "pry"
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end


require "invoker"
require "invoker/power/power"
MM = Invoker::IPC::Message

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.mock_framework = :mocha

  config.before(:each) do
    @original_verbosity = $VERBOSE
    $VERBOSE = nil
    @old_config = Invoker::Power::Config::CONFIG_LOCATION
    Invoker::Power::Config.const_set(:CONFIG_LOCATION, "/tmp/.invoker/config")

    File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)

    @old_resolver = Invoker::Power::Setup::RESOLVER_FILE
    Invoker::Power::Setup.const_set(:RESOLVER_FILE, "/tmp/resolver/invoker-dev")
    Invoker::Power::Setup.const_set(:RESOLVER_DIR, "/tmp/resolver")

    unless Dir.exists?(Invoker::Power::Setup::RESOLVER_DIR)
      FileUtils.mkdir(Invoker::Power::Setup::RESOLVER_DIR)
    end

    File.exists?(Invoker::Power::Setup::RESOLVER_FILE) &&
      File.delete(Invoker::Power::Setup::RESOLVER_FILE)
  end

  config.after(:each) do
    File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)

    Invoker::Power::Config.const_set(:CONFIG_LOCATION, @old_config)

    File.exists?(Invoker::Power::Setup::RESOLVER_FILE) &&
      File.delete(Invoker::Power::Setup::RESOLVER_FILE)

    FileUtils.rm_rf(Invoker::Power::Setup::RESOLVER_DIR)
    Invoker::Power::Setup.const_set(:RESOLVER_FILE, @old_resolver)

    $VERBOSE = @original_verbosity
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

ENV["INVOKER_TESTS"] = "true"

def invoker_config
  Invoker.config ||= mock
end

def invoker_commander
  Invoker.commander ||= mock
end

def invoker_dns_cache
  Invoker.dns_cache ||= mock
end
