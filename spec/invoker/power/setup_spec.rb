require "spec_helper"

describe "Setup" do
  before {
    @old_config = Invoker::Power::Config::CONFIG_LOCATION
    Invoker::Power::Config.const_set(:CONFIG_LOCATION, "/tmp/.invoker")

    File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)

    @old_resolver = Invoker::Power::Setup::RESOLVER_FILE
    Invoker::Power::Setup.const_set(:RESOLVER_FILE, "/tmp/invoker-dev")

    File.exists?(Invoker::Power::Setup::RESOLVER_FILE) &&
      File.delete(Invoker::Power::Setup::RESOLVER_FILE)
  }

  after {
    File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)

    Invoker::Power::Config.const_set(:CONFIG_LOCATION, @old_config)

    File.exists?(Invoker::Power::Setup::RESOLVER_FILE) &&
      File.delete(Invoker::Power::Setup::RESOLVER_FILE)
    Invoker::Power::Setup.const_set(:RESOLVER_FILE, @old_resolver)
  }

  describe "When no setup existis" do
    it "should create a config file with port etc" do
      setup = Invoker::Power::Setup.new()
      setup.expects(:install_resolver).returns(true)
      setup.expects(:flush_dns_rules).returns(true)
      setup.expects(:drop_to_normal_user).returns(true)
      setup.expects(:install_firewall).returns("010")

      setup.setup_invoker

      config = Invoker::Power::Config.load_config()
      config.http_port.should.not == nil
      config.dns_port.should.not == nil
      config.ipfw_rule_number.should == "010"
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
        @setup.expects(:install_firewall).returns("010")

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
end
