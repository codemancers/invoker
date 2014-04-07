require "spec_helper"

describe Invoker::CLI::Pinger do
  let(:unix_client) { Invoker::IPC::UnixClient.new }
  let(:pinger) { Invoker::CLI::Pinger.new(unix_client) }
  let(:pong) { MM::Pong.new(status: 'pong') }

  context "If Invoker is running" do
    it "should return true" do
      unix_client.expects(:send_and_receive).returns(pong)
      expect(pinger.invoker_running?).to be_true
    end
  end

  context "if Invoker is not running" do
    it "should return false" do
      unix_client.expects(:send_and_receive).returns(nil)
      unix_client.expects(:abort).never
      expect(pinger.invoker_running?).to be_false
    end
  end
end
