require "timeout"

module Invoker
  class CLI::Pinger
    attr_accessor :unix_client
    def initialize(unix_client)
      @unix_client = unix_client
    end

    def invoker_running?
      response = send_ping_and_read_response
      response && response.status == 'pong'
    end

    private

    def send_ping_and_read_response
      Timeout.timeout(2) { unix_client.send_and_receive('ping') }
    rescue Timeout::Error
      nil
    end
  end
end
