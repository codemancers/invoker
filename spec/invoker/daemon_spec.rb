require "spec_helper"

describe Invoker::Daemon do
  describe '.start' do
    it "should start the daemon" do
      Daemons.expects(:daemonize)
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
