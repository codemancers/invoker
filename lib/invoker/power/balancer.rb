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

    class BalancerParser
      attr_accessor :host, :parser
      def initialize
        @parser = HTTP::Parser.new()
        @header = {}
        @parser.on_headers_complete { headers_received() }
        @parser.on_header_field { |field_name| @last_key = field_name }
        @parser.on_header_value { |value| header_value_received(value) }
      end

      def headers_received
        @header_completion_callback.call(@header)
      end

      def header_value_received(value)
        @header[@last_key] = value
      end

      def on_headers_complete(&block)
        @header_completion_callback = block
      end

      def reset; @parser.reset(); end

      def <<(data)
        @parser << data
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
        @http_parser = BalancerParser.new()
        @session = nil
        @buffer = []
      end

      def install_callbacks
        http_parser.on_headers_complete { |header| headers_received(header) }
        connection.on_data {|data| upstream_data(data) }
        connection.on_response { |backend, data| backend_data(backend, data) }
        connection.on_finish { |backend, name| frontend_disconnect(backend, name) }
      end

      def headers_received(header)
        @session = UUID.generate()
        matching_string = header['Host'].match(/(\w+)\.dev$/)
        http_parser.reset()
        if matching_string && selected_app = matching_string[1]
          config = Invoker::CONFIG.process(selected_app)
          if config
            connection.server(session, host: '0.0.0.0', port: config.port)
            connection.relay_to_servers(@buffer.join)
            @buffer = []
          else
            connection.unbind
          end
        else
          connection.unbind
        end
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
