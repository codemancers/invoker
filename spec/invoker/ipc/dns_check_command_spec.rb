require 'spec_helper'

describe Invoker::IPC::DnsCheckCommand do
  let(:client_socket) { StringIO.new }
  let(:client) { Invoker::IPC::ClientHandler.new(client_socket) }

  describe "dns check for valid process" do
    let(:message_object) { MM::DnsCheck.new(process_name: 'foo') }
    it "should response with dns check response" do
      invoker_dns_cache.expects(:[]).returns('port' => 9000)
      client_socket.string = message_object.encoded_message

      client.read_and_execute

      dns_check_response = client_socket.string
      expect(dns_check_response).to match(/9000/)
    end
  end

  describe "dns check for invalid process" do
    let(:message_object) { MM::DnsCheck.new(process_name: 'foo') }
    it "should response with dns check response" do
      invoker_dns_cache.expects(:[]).returns('port' => nil)
      client_socket.string = message_object.encoded_message

      client.read_and_execute

      dns_check_response = client_socket.string
      expect(dns_check_response).to match(/null/)
    end
  end
end
