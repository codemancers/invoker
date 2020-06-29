require "spec_helper"
require "invoker/power/setup/distro/ubuntu"
require "invoker/power/setup/distro/opensuse"

def mock_socat_scripts
  FakeFS.deactivate!
  socat_content = File.read(invoker_setup.forwarder_script)
  socat_systemd = File.read(invoker_setup.socat_unit)
  FakeFS.activate!
  FileUtils.mkdir_p(File.dirname(invoker_setup.forwarder_script))
  FileUtils.mkdir_p(File.dirname(invoker_setup.socat_unit))
  File.open(invoker_setup.socat_unit, "w") do |fl|
    fl.write(socat_systemd)
  end
  File.open(invoker_setup.forwarder_script, "w") do |fl|
    fl.write(socat_content)
  end
  FileUtils.mkdir_p("/usr/bin")
  FileUtils.mkdir_p("/etc/systemd/system")
end

describe Invoker::Power::LinuxSetup, fakefs: true do
  before do
    FileUtils.mkdir_p(inv_conf_dir)
    FileUtils.mkdir_p(Invoker::Power::Distro::Base::RESOLVER_DIR)
    Invoker.config = mock
  end

  let(:invoker_setup) { Invoker::Power::LinuxSetup.new('test') }
  let(:distro_installer) { Invoker::Power::Distro::Ubuntu.new('test') }

  before do
    invoker_setup.distro_installer = distro_installer
  end

  it "should only proceed after user confirmation" do
    distro_installer.expects(:get_user_confirmation?).returns(false)

    invoker_setup.setup_invoker

    expect { Invoker::Power::Config.load_config }.to raise_error(Errno::ENOENT)
  end

  it "should create config file with http(s) ports" do
    invoker_setup.expects(:initialize_distro_installer).returns(true)
    invoker_setup.expects(:install_resolver).returns(true)
    invoker_setup.expects(:install_port_forwarder).returns(true)
    invoker_setup.expects(:drop_to_normal_user).returns(true)

    distro_installer.expects(:get_user_confirmation?).returns(true)
    distro_installer.expects(:install_required_software)
    distro_installer.expects(:restart_services)

    invoker_setup.setup_invoker

    config = Invoker::Power::Config.load_config
    expect(config.tld).to eq('test')
    expect(config.http_port).not_to be_nil
    expect(config.dns_port).to be_nil
    expect(config.https_port).not_to be_nil
  end

  describe "configuring services" do
    let(:config) { Invoker::Power::Config.load_config }

    before(:all) do
      @original_invoker_config = Invoker.config
    end

    after(:all) do
      Invoker.config = @original_invoker_config
    end

    before(:each) do
      mock_socat_scripts
    end

    def run_setup
      invoker_setup.expects(:initialize_distro_installer).returns(true)
      invoker_setup.expects(:drop_to_normal_user).returns(true)

      distro_installer.expects(:get_user_confirmation?).returns(true)
      distro_installer.expects(:install_required_software)
      distro_installer.expects(:restart_services)

      invoker_setup.setup_invoker
    end

    def test_socat_config
      socat_content = File.read(Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT)
      expect(socat_content.strip).to_not be_empty
      expect(socat_content.strip).to match(/#{config.https_port}/)
      expect(socat_content.strip).to match(/#{config.http_port}/)

      service_file = File.read(Invoker::Power::Distro::Base::SOCAT_SYSTEMD)
      expect(service_file.strip).to_not be_empty
    end

    context 'on ubuntu with systemd-resolved' do
      it "should create socat config & set tld to localhost" do
        distro_installer.expects(:using_systemd_resolved?).at_least_once.returns(true)
        run_setup
        expect(distro_installer.resolver_file).to be_nil
        test_socat_config
        expect(config.tld).to eq('localhost')
      end
    end

    context 'on non-systemd-resolved distro' do
      it "should create dnsmasq & socat configs" do
        run_setup
        dnsmasq_content = File.read(distro_installer.resolver_file)
        expect(dnsmasq_content.strip).to_not be_empty
        expect(dnsmasq_content).to match(/test/)

        test_socat_config
      end
    end
  end

  describe 'resolver file' do
    context 'user sets up a custom top level domain' do
      let(:tld) { 'local' }
      let(:linux_setup) { Invoker::Power::LinuxSetup.new(tld) }

      context 'on ubuntu with systemd-resolved' do
        it 'should not create a resolver file' do
          ubuntu_installer = Invoker::Power::Distro::Ubuntu.new(tld)
          linux_setup.distro_installer = ubuntu_installer
          ubuntu_installer.expects(:using_systemd_resolved?).at_least_once.returns(true)
          expect(linux_setup.resolver_file).to eq(nil)
        end
      end

      context 'on non-systemd-resolved distro' do
        it 'should create the correct resolver file' do
          suse_installer = Invoker::Power::Distro::Opensuse.new(tld)
          linux_setup.distro_installer = suse_installer
          expect(linux_setup.resolver_file).to eq("/etc/dnsmasq.d/#{tld}-tld")
        end
      end
    end
  end
end

describe Invoker::Power::Distro::Base, docker: true do
  describe '.distro_installer' do
    it 'correctly recognizes the current distro' do
      case ENV['DISTRO']
      when 'archlinux', 'manjarolinux/base'
        expect(described_class.distro_installer('')).to be_a Invoker::Power::Distro::Arch
      when 'debian'
        expect(described_class.distro_installer('')).to be_a Invoker::Power::Distro::Debian
      when 'fedora'
        expect(described_class.distro_installer('')).to be_a Invoker::Power::Distro::Redhat
      when 'linuxmintd/mint20-amd64', 'ubuntu'
        expect(described_class.distro_installer('')).to be_a Invoker::Power::Distro::Ubuntu
      when 'opensuse/leap', 'opensuse/tumbleweed'
        expect(described_class.distro_installer('')).to be_a Invoker::Power::Distro::Opensuse
      when nil
      else
        raise 'Unrecognized Linux distro. Please add the appropriate docker image to the travis build matrix, update the described method, and add a case here.'
      end
    end
  end
end
