require "spec_helper"

describe Invoker::Power::PfMigrate do
  before do
    @old_firewall_file = Invoker::Power::OsxSetup::FIREWALL_PLIST_FILE
    Invoker::Power::OsxSetup.const_set(:FIREWALL_PLIST_FILE, "/tmp/.invoker/firewall")
  end

  after do
    Invoker::Power::OsxSetup.const_set(:FIREWALL_PLIST_FILE, @old_firewall_file)
  end

  let(:pf_migrator) { Invoker::Power::PfMigrate.new }

  describe "#firewall_config_requires_migration?" do
    context "for nonosx systems " do
      it "should return false" do
        Invoker.expects(:darwin?).returns(false)
        expect(pf_migrator.firewall_config_requires_migration?).to eq(false)
      end
    end

    context "for osx systems" do
      before { Invoker.expects(:darwin?).returns(true) }

      context "for osx < yosemite" do
        it "should return false" do
          pf_migrator.expects(:osx_version).returns(Invoker::Version.new("13.4.0"))
          expect(pf_migrator.firewall_config_requires_migration?).to eq(false)
        end
      end

      context "for osx > yosemite with existing ipfw rule" do
        before do
          write_to_firewall_file("ipfw firewall rule")
        end
        it "should return true" do
          pf_migrator.expects(:osx_version).returns(Invoker::Version.new("14.0.0"))
          expect(pf_migrator.firewall_config_requires_migration?).to eql(true)
        end
      end

      context "for osx >= yosemite with no ipfw rule" do
        before do
          write_to_firewall_file("rdr pass on")
        end
        it "should return false" do
          pf_migrator.expects(:osx_version).returns(Invoker::Version.new("14.0.0"))
          expect(pf_migrator.firewall_config_requires_migration?).to eql(false)
        end
      end
    end
  end

  describe "#migrate" do
    before do
      mock_config = mock()
      mock_config.stubs(:http_port).returns(80)
      mock_config.stubs(:https_port).returns(443)
      Invoker.config = mock_config
    end

    it "should migrate firewall to new system" do
      pf_migrator.expects(:firewall_config_requires_migration?).returns(true)
      pf_migrator.expects(:ask_user_for_migration).returns(true)
      pf_migrator.expects(:sudome)
      pf_migrator.expects(:drop_to_normal_user)
      pf_migrator.expects(:exit)

      pf_migrator.migrate
      expect(pf_migrator.check_firewall_file?).to eql(false)
    end
  end

  def write_to_firewall_file(content)
    File.open(Invoker::Power::OsxSetup::FIREWALL_PLIST_FILE, "w") do |fl|
      fl.write(content)
    end
  end
end
