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
        expect(File.exists?(Invoker::Power::Config::CONFIG_LOCATION)).to be_true

        config = Invoker::Power::Config.load_config()
        expect(config.dns_port).to eq(1200)
        expect(config.http_port).to eq(1201)
        expect(config.ipfw_rule_number).to eq(010)
      ensure
        File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
          File.delete(Invoker::Power::Config::CONFIG_LOCATION)
      end
    end
  end
end
