require "pry"
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end


require "invoker"
require "invoker/power/power"
require "spec/support/mock_setup_file"
MM = Invoker::IPC::Message

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.mock_framework = :mocha

  config.around do |example|
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    setup_mocked_config_files
    example.run
    remove_mocked_config_files
    $VERBOSE = original_verbosity
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
