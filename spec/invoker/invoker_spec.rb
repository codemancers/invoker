require "spec_helper"

describe "Invoker" do
  describe "#darwin?" do
    it "should return true on osx" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      expect(Invoker.darwin?).to be_true
    end

    it "should return false on linux" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      expect(Invoker.darwin?).to be_false
    end
  end

  describe "#can_run_balancer?" do
    before {
      File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)
    }

    after {
      File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)
    }

    it "should return false if setup command was not run on osx" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      expect(Invoker.can_run_balancer?).to be_false
    end

    it "should return false if platform is not osx" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      expect(Invoker.can_run_balancer?).to be_false
    end

    it "should return true if setup was run properly" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      File.open(Invoker::Power::Config::CONFIG_LOCATION, "w") {|fl|
        fl.write("hello")
      }

      expect(Invoker.can_run_balancer?).to be_true
    end

    it "should not print warning if setup is not run when flag is false" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      Invoker::Logger.expects(:puts).never()
      Invoker.can_run_balancer?(false)
    end
  end

  describe "#setup_config_location" do
    before do
      Dir.stubs(:home).returns('/tmp')
      @config_location = File.join('/tmp', '.invoker')
      FileUtils.rm_rf(@config_location)
    end

    context "when the old config file does not exist" do
      it "creates the new config directory" do
        Invoker.setup_config_location
        expect(Dir.exist?(@config_location)).to be_true
      end
    end

    context "when the old config file exists" do
      before do
        File.open(@config_location, 'w') do |file|
          file.write('invoker config')
        end
      end

      it "moves the file to the new directory" do
        Invoker.setup_config_location
        expect(Dir.exist?(@config_location)).to be_true
        new_config_file = File.join(@config_location, 'config')
        expect(File.exist?(new_config_file)).to be_true
        expect(File.read(new_config_file)).to match('invoker config')
      end
    end
  end
end
