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
      attr_accessor :connection, :http_parser, :session

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
        @session = nil
        @buffer = []
      end

      def install_callbacks
        http_parser.on_headers_complete method(:headers_received)
        connection.on_data method(:upstream_data)
        connection.on_response method(:backend_data)
        connection.on_finish method(:frontend_disconnect)
      end

      def reset_parser
        @buffer = []
        @http_parser.clear()
      end

      def headers_received(header)
        @session = UUID.generate()
        host = header['Host']
        selected_app = host.split(".",2)[1]
        config = Invoker::CONFIG.process(selected_app)
        if config
          connection.server(session, host: '0.0.0.0', port: config.port)
          connection.relay_to_servers(@buffer.join)
        end
        :stop
      end

      def upsteam_data(data)
        if session
          @buffer << data
          @http_parser << data
          nil
        else
          data
        end
      end

      def backend_data(backend, data)
        data
      end

      def frontend_disconnect(backend, name)
        puts "connection termination is not handled"
      end
    end
  end
end
