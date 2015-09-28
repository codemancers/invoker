require 'spec_helper'

describe Invoker::Power::Balancer do
  before do
    @http_connection = mock("connection")
    @balancer = Invoker::Power::Balancer.new(@http_connection, "http")
  end

  context "when Host field is missing in the request" do
    it "should return 400 as response when Host is missing" do
      headers = {}
      @http_connection.expects(:send_data).with() { |value| value =~ /400 Bad Request/i }
      @balancer.headers_received(headers)
    end

    it "should return 400 as response when Host is empty" do
      headers = { 'Host' => '' }
      @http_connection.expects(:send_data).with() { |value| value =~ /400 Bad Request/i }
      @balancer.headers_received(headers)
    end
  end

  describe "#backend_host" do
    it "should return localhost as default when backend host is not configured" do
      Invoker.backend_host = nil
      expect(@balancer.backend_host).to eql("0.0.0.0")
    end

    it "should return as per configured backend host" do
      Invoker.backend_host = "192.168.59.103"
      expect(@balancer.backend_host).to eql("192.168.59.103")
    end
  end
end
