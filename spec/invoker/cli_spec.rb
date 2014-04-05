require "spec_helper"

describe Invoker::CLI do
  describe "default start command" do
    before do
      Invoker.expects(:setup_config_location)
    end

    it "should use default if no other command specified" do
      Invoker::CLI.any_instance.expects(:start).with("dummy")
      Invoker::CLI.start(["dummy"])
    end

    it "should use proper command if it exists" do
      Invoker::CLI.any_instance.expects(:list)
      Invoker::CLI.start(["list"])
    end

    it "should list version" do
      Invoker::CLI.any_instance.expects(:version)
      Invoker::CLI.start(["-v"])
    end
  end

  describe "stop command" do
    it "should stop the daemon" do
      Invoker.expects(:setup_config_location)
      Invoker.daemon.expects(:stop).once
      Invoker::CLI.start(["stop"])
    end
  end

  describe "setup config location" do
    before do
      Dir.stubs(:home).returns('/tmp')
      @config_location = File.join('/tmp', '.invoker')
      FileUtils.rm_rf(@config_location)
    end

    context "when the old config file does not exist" do
      it "creates the new config directory" do
        Invoker::CLI.any_instance.expects(:version)
        Invoker::CLI.start(["-v"])
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
        Invoker::CLI.any_instance.expects(:start)
        Invoker::CLI.start(["start"])
        expect(Dir.exist?(@config_location)).to be_true
        new_config_file = File.join(@config_location, 'config')
        expect(File.exist?(new_config_file)).to be_true
        expect(File.read(new_config_file)).to match('invoker config')
      end
    end
  end
end
