require "spec_helper"

describe Invoker::Daemon do
  let(:daemon) { Invoker::Daemon.new}

  describe "#start" do
    context "when daemon is aleady running" do
      it "exits without any error" do
        daemon.expects(:running?).returns(true)
        begin
          daemon.start
        rescue SystemExit => e
          expect(e.status).to be(0)
        end
      end
    end

    context "when daemon is not running" do
      it "starts the daemon" do
        daemon.expects(:dead?).returns(false)
        daemon.expects(:running?).returns(false)
        daemon.expects(:daemonize)
        daemon.start
      end
    end
  end

  describe "#stop" do
    it "stops the daemon" do
      daemon.expects(:kill_process)
      daemon.stop
    end
  end
end
