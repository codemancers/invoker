require "spec_helper"

require "tempfile"

describe "Invoker::Config" do
  describe "with invalid directory" do
    it "should raise error during startup" do
      begin
        file = Tempfile.new("invalid_config.ini")

        config_data =<<-EOD
[try_sleep]
directory = /Users/gnufied/foo
command = ruby try_sleep.rb
      EOD
        file.write(config_data)
        file.close
        lambda {
          Invoker::Parsers::Config.new(file.path)
        }.should.raise(Invoker::Errors::InvalidConfig)
      ensure
        file.unlink()
      end
    end
  end
end

