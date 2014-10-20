require "spec_helper"

describe Invoker::Power::PfMigrate do
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
          expect(pf_migrator.firewall_config_requires_migration?).to eq(true)
        end
      end

      context "for osx > yosemite with existing ipfw rule" do
        it "should return true" do
        end
      end

      context "for osx >= yosemite with no ipfw rule" do
        it "should return false" do
        end
      end
    end
  end

  describe "#migrate" do
    it "should migrate firewall to new system" do
    end
  end
end
