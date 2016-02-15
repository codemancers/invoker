require "spec_helper"
require "invoker/power/setup/distro/ubuntu"

describe Invoker::Power::LinuxSetup do
  let(:invoker_setup) { Invoker::Power::LinuxSetup.new }
  let(:distro_installer) { Invoker::Power::Distro::Ubuntu.new }

  describe "should only proceed after user confirmation" do
    before { invoker_setup.distro_installer = distro_installer }

    it "should create config file with port" do
      invoker_setup.expects(:initialize_distro_installer).returns(true)
      invoker_setup.expects(:get_user_confirmation?).returns(true)
      invoker_setup.expects(:install_resolver).returns(true)
      invoker_setup.expects(:install_port_forwarder).returns(true)
      invoker_setup.expects(:drop_to_normal_user).returns(true)

      distro_installer.expects(:install_required_software)
      distro_installer.expects(:restart_services)

      invoker_setup.setup_invoker

      config = Invoker::Power::Config.load_config
      expect(config.http_port).not_to be_nil
      expect(config.dns_port).to be_nil
      expect(config.https_port).not_to be_nil
    end
  end

  describe "configuring dnsmasq and socat" do
    before(:all) do
      @original_invoker_config = Invoker.config
      Invoker.config = mock
    end

    after(:all) do
      Invoker.config = @original_invoker_config
    end

    before(:each) do
      invoker_setup.distro_installer = distro_installer
    end

    it "should create proper config file" do
      invoker_setup.expects(:initialize_distro_installer).returns(true)
      invoker_setup.expects(:get_user_confirmation?).returns(true)
      invoker_setup.expects(:drop_to_normal_user).returns(true)

      distro_installer.expects(:install_required_software)
      distro_installer.expects(:restart_services)

      invoker_setup.setup_invoker

      config = Invoker::Power::Config.load_config

      dnsmasq_content = File.read(distro_installer.resolver_file)
      expect(dnsmasq_content.strip).to_not be_empty
      expect(dnsmasq_content).to match(/dev/)

      socat_content = File.read(distro_installer.socat_script)
      expect(socat_content.strip).to_not be_empty
      expect(socat_content.strip).to match(/#{config.https_port}/)
      expect(socat_content.strip).to match(/#{config.http_port}/)

      service_file = File.read(distro_installer.socat_systemd)
      expect(service_file.strip).to_not be_empty
    end
  end

  describe 'resolver file' do
    context 'user sets up a custom top level domain' do
      before(:all) do
        original_tld = Invoker::Power::Setup.tld
        Invoker::Power::Setup.tld = 'local'
      end

      it 'should create the correct resolver file' do
        remove_mocked_config_files

        expect(Invoker::Power::Distro::Ubuntu.resolver_file).to eq('/etc/dnsmasq.d/local-tld')

        setup_mocked_config_files
      end

      after(:all) do
        Invoker::Power::Setup.tld = original_tld
      end
    end

    context "user doesn't setup a custom top level domain" do
      it 'should create the correct resolver file' do
        remove_mocked_config_files

        expect(Invoker::Power::Distro::Ubuntu.resolver_file).to eq('/etc/dnsmasq.d/dev-tld')

        setup_mocked_config_files
      end
    end
  end
end
