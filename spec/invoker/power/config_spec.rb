require "spec_helper"

describe "Invoker Power configuration", fakefs: true do
  describe "#create" do
    it "should create a config file given a hash" do
      FileUtils.mkdir_p(inv_conf_dir)
      config = Invoker::Power::Config.create(
        dns_port: 1200, http_port: 1201, ipfw_rule_number: 010
      )
      expect(File.exist?(Invoker::Power::Config.config_file)).to be_truthy

      config = Invoker::Power::Config.load_config()
      expect(config.dns_port).to eq(1200)
      expect(config.http_port).to eq(1201)
      expect(config.ipfw_rule_number).to eq(010)
    end
  end
end
