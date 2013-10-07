require "spec_helper"

describe "Invoker Power configuration" do
  describe "#create" do
    it "should create a config file given a hash" do
      begin
        File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
          File.delete(Invoker::Power::Config::CONFIG_LOCATION)
        config = Invoker::Power::Config.create(
          dns_port: 1200, http_port: 1201, ipfw_rule_number: 010
        )
        File.exists?(Invoker::Power::Config::CONFIG_LOCATION).should == true

        config = Invoker::Power::Config.load_config()
        config.dns_port.should == 1200
        config.http_port.should == 1201
        config.ipfw_rule_number.should == 010
      ensure
        File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
          File.delete(Invoker::Power::Config::CONFIG_LOCATION)
      end
    end
  end
end
