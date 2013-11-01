require "spec_helper"

describe "Setup" do
  describe "When no setup exists" do
    it "should create a config file with port etc" do
      setup = Invoker::Power::Setup.new()
      setup.expects(:install_resolver).returns(true)
      setup.expects(:flush_dns_rules).returns(true)
      setup.expects(:drop_to_normal_user).returns(true)
      setup.expects(:install_firewall).once()

      setup.setup_invoker

      config = Invoker::Power::Config.load_config()
      expect(config.http_port).not_to be_nil
      expect(config.dns_port).not_to be_nil
    end
  end

  describe "setup on non osx systems" do
    it "should not run setup" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      Invoker::Power::Setup.any_instance.expects(:check_if_setup_can_run?).never()
      Invoker::Power::Setup.install
    end
  end

  describe "when a setup file exists" do
    it "should throw error about existing file" do
      File.open(Invoker::Power::Config::CONFIG_LOCATION, "w") {|fl|
        fl.write("foo test")
      }
      Invoker::Power::Setup.any_instance.expects(:setup_invoker).never
      Invoker::Power::Setup.install()
    end
  end

  describe "when pow like setup exists" do
    before {
      File.open(Invoker::Power::Setup::RESOLVER_FILE, "w") {|fl|
        fl.write("hello")
      }
      @setup = Invoker::Power::Setup.new
    }

    describe "when user selects to overwrite it" do
      it "should run setup normally" do
        @setup.expects(:setup_resolver_file).returns(true)
        @setup.expects(:drop_to_normal_user).returns(true)
        @setup.expects(:install_resolver).returns(true)
        @setup.expects(:flush_dns_rules).returns(true)
        @setup.expects(:install_firewall).once()

        @setup.setup_invoker
      end
    end

    describe "when user chose not to overwrite it" do
      it "should abort the setup process" do
        @setup.expects(:setup_resolver_file).returns(false)

        @setup.expects(:install_resolver).never
        @setup.expects(:flush_dns_rules).never
        @setup.expects(:install_firewall).never

        @setup.setup_invoker
      end
    end
  end

  describe "uninstalling firewall rules" do
    it "should uninstall firewall rules and remove all files created by setup" do
      setup = Invoker::Power::Setup.new

      HighLine.any_instance.expects(:agree).returns(true)
      setup.expects(:remove_resolver_file).once
      setup.expects(:unload_firewall_rule).with(true).once
      setup.expects(:flush_dns_rules).once
      Invoker::Power::Config.expects(:delete).once

      setup.uninstall_invoker
    end
  end
end
