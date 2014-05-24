require "spec_helper"

describe Invoker::Power::LinuxSetup do
  let(:invoker_setup) { Invoker::Power::LinuxSetup.new }
  describe "should only proceed after user confirmation" do
    it "should create config file with port" do
      invoker_setup.expects(:get_user_confirmation?).returns(true)
      invoker_setup.expects(:install_required_software).returns(true)
      invoker_setup.expects(:install_resolver).returns(true)
      invoker_setup.expects(:install_port_forwarder).returns(true)
      invoker_setup.expects(:restart_services).returns(true)
      invoker_setup.expects(:drop_to_normal_user).returns(true)

      invoker_setup.setup_invoker

      config = Invoker::Power::Config.load_config
      expect(config.http_port).not_to be_nil
      expect(config.dns_port).to be_nil
      expect(config.https_port).not_to be_nil
    end
  end

  describe "configuring dnsmasq and rinetd" do
    it "should create proper config file" do
      invoker_setup.expects(:get_user_confirmation?).returns(true)
      invoker_setup.expects(:install_required_software).returns(true)
      invoker_setup.expects(:restart_services).returns(true)
      invoker_setup.expects(:drop_to_normal_user).returns(true)

      invoker_setup.setup_invoker

      config = Invoker::Power::Config.load_config

      dnsmasq_content = File.read(Invoker::Power::LinuxSetup::RESOLVER_FILE)
      expect(dnsmasq_content.strip).to_not be_empty
      expect(dnsmasq_content).to match(/dev/)

      rinetd_content = File.read(Invoker::Power::LinuxSetup::RINETD_FILE)
      expect(rinetd_content.strip).to_not be_empty
      expect(rinetd_content.strip).to match(/#{config.https_port}/)
      expect(rinetd_content.strip).to match(/#{config.http_port}/)
    end
  end
end
