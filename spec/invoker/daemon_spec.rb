require "spec_helper"

describe Invoker::Daemon do
  describe '.start' do
    it "should start the daemon" do
      pwd = mock()
      Dir.expects(:pwd).returns(pwd)
      Daemons.expects(:daemonize)
      Dir.expects(:chdir).with(pwd)
      Invoker::Daemon.start
    end
  end

  describe '.stop' do
    it "should stop the daemon if it is running" do
      monitor = mock()
      Daemons::Monitor.expects(:find).returns(monitor)
      monitor.expects(:stop).once
      Invoker::Daemon.stop
    end
  end
end
