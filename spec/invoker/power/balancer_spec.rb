require 'spec_helper'

describe Invoker::Power::Balancer do
  before do
    @http_connection = mock("connection")
    @balancer = Invoker::Power::Balancer.new(@http_connection, "http")
  end

  context "when Host field is not capitalized" do
    before(:all) do
      @original_invoker_config = Invoker.config
    end

    def mock_invoker_tld_as(domain)
      Invoker.config = mock
      Invoker.config.stubs(:tld).returns(domain)
    end

    after(:all) do
      Invoker.config = @original_invoker_config
    end

    it "should not return 400 when host is lowercase" do
      headers = { 'host' => 'somehost.com' }
      mock_invoker_tld_as('test')
      @http_connection.expects(:send_data).with() { |value| value =~ /404 Not Found/i }
      @http_connection.expects(:close_connection_after_writing)
      @balancer.headers_received(headers)
    end

    it "should not return 400 when host is written as HoSt" do
      headers = { 'HoSt' => 'somehost.com' }
      mock_invoker_tld_as('test')
      @http_connection.expects(:send_data).with() { |value| value =~ /404 Not Found/i }
      @http_connection.expects(:close_connection_after_writing)
      @balancer.headers_received(headers)
    end
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
end
