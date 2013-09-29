module Invoker
  module Power
    class BalancerConnection < EventMachine::ProxyServer::Connection
      attr_accessor :host_known, :host, :ip, :port
      def set_host(host, selected_backend)
        self.host = host
        self.ip = selected_backend[:host]
        self.port = selected_backend[:port]
        self.host_known = true
      end
    end

    class Balancer
      attr_accessor :connection, :http_parser

      def self.run(options = {})
        EventMachine.start_server('0.0.0.0', 23401,
                                  BalancerConnection, options) do |connection|
          balancer = Balancer.new(connection)
          balancer.install_callbacks
        end
      end

      def initialize(connection)
        @connection = connection
        @http_parser = Http::Parser.new()
      end

      def install_callbacks
        connection.on_data { }
        connection.on_response {}
        connection.on_finish {}
      end
    end
  end
end
