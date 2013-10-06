require "spec_helper"

describe "Setup" do
  context "When no setup existis" do
    it "should create a config file with port etc" do
      Invoker::Power::Setup.install()

      config = Invoker::Power::Config.load_config()
      config.http_port.should.not be_nil
      config.dns_port.should.not be_nil
    end
  end
end
