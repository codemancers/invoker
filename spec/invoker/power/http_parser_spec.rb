require "spec_helper"

describe Invoker::Power::HttpParser do
  let(:parser) { Invoker::Power::HttpParser.new('https') }

  describe "complete message received" do
    before { parser.reset }
    it "should call header received with full header" do
      @header = nil
      parser.on_headers_complete { |header| @header = header }
      parser << "HTTP/1.1 200 OK\r\n"
      parser << "Content-Type: text/plain;charset=utf-8\r\n"
      parser << "Content-Length: 5\r\n"
      parser << "Connection: close\r\n\r\n"
      parser << "hello"

      expect(@header['Content-Type']).to eql "text/plain;charset=utf-8"
      expect(parser.raw_header_data.string).to eql "HTTP/1.1 200 OK\r\nContent-Type: text/plain;charset=utf-8\r\nContent-Length: 5\r\nConnection: close\r\n\r\n"
    end

    it "should return complete message with x_forwarded added" do
      complete_message = nil
      parser.on_message_complete { |message| complete_message = message }
      parser.on_headers_complete { |header| @header = header }
      parser << "HTTP/1.1 200 OK\r\n"
      parser << "Content-Type: text/plain;charset=utf-8\r\n"
      parser << "Content-Length: 5\r\n"
      parser << "Connection: close\r\n\r\n"
      parser << "hello"
      expect(complete_message).to match(/X_FORWARDED_PROTO:/i)
    end
  end
end
