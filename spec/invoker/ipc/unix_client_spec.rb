require "spec_helper"

describe Invoker::IPC::UnixClient do
  let(:unix_client) { described_class.new }
  let(:socket) { StringIO.new }

  describe "serializing a " do
    it "list request should work" do
      unix_client.expects(:open_client_socket).yields(socket)
      unix_client.send_command("list")

      expect(socket.string).to match(/list/)
    end

    it "add request should work" do
      unix_client.expects(:open_client_socket).yields(socket)
      unix_client.send_command("add", process_name: "hello")

      expect(socket.string).to match(/hello/)
    end
  end
end
