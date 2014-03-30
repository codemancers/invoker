require "spec_helper"

describe Invoker::CLI do
  describe "default start command" do
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
    before do
      Invoker.const_set(:DAEMON_APP_NAME, 'invoker')
      Invoker.const_set(:DAEMON_APP_DIR, '/tmp')
    end

    after do
      Invoker.send(:remove_const, :DAEMON_APP_NAME)
      Invoker.send(:remove_const, :DAEMON_APP_DIR)
    end

    it "should stop the daemon" do
      Invoker::Daemon.expects(:stop).once
      Invoker::CLI.start(["stop"])
    end
  end
end
