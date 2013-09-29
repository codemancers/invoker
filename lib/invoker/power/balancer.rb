module Invoker
  module Power
    class BalancerConnection < EventMachine::ProxyServer::Connection
      attr_accessor :host, :ip, :port
      def set_host(host, selected_backend)
        self.host = host
        self.ip = selected_backend[:host]
        self.port = selected_backend[:port]
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
        http_parser.on_headers_complete = method(:headers_received)
        connection.on_data {|data| upstream_data(data) }
        connection.on_response { |backend, data| backend_data(backend, data) }
        connection.on_finish { |backend, name| frontend_disconnect(backend, name) }
      end

      def headers_received(header)
        @session = UUID.generate()
        selected_app = header['Host'].match(/(\w+)\.dev$/)[1]
        config = Invoker::CONFIG.process(selected_app)
        if config
          connection.server(session, host: '0.0.0.0', port: config.port)
          connection.relay_to_servers(@buffer.join)
          @buffer = []
        end
        :stop
      end

      def upstream_data(data)
        unless session
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
        connection.unbind if backend == session
      end
    end
  end
end
