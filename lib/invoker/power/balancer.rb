require 'em-proxy'
require 'http-parser'

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
        @parser.on_header_field { |field_name|
          @last_key = field_name
        }
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
      DEV_MATCH_REGEX = /([\w-]+)\.dev(\:\d+)?$/

      def self.run(options = {})
        EventMachine.start_server('0.0.0.0', Invoker::CONFIG.http_port,
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
        dns_check_response = select_backend_config(header['Host'])
        if dns_check_response && dns_check_response.port
          connection.server(session, host: '0.0.0.0', port: dns_check_response.port)
          connection.relay_to_servers(@buffer.join)
          @buffer = []
        else
          return_error_page(404)
          connection.close_connection_after_writing
        end
      end

      def upstream_data(data)
        unless session
          @buffer << data
          append_for_http_parsing(data)
          nil
        else
          data
        end
      end

      def append_for_http_parsing(data)
        http_parser << data
      rescue HTTP::Parser::Error
        http_parser.reset
        connection.close_connection_after_writing
      end

      def backend_data(backend, data)
        @backend_data = true
        data
      end

      def frontend_disconnect(backend, name)
        http_parser.reset()
        unless @backend_data
          Invoker::Logger.puts("\nApplication not running. Returning error page.".color(:red))
          return_error_page(503)
        end
        @backend_data = false
        connection.close_connection_after_writing() if backend == session
      end

      def extract_host_from_domain(host)
        host.match(DEV_MATCH_REGEX)
      end

      private

      def select_backend_config(host)
        matching_string = extract_host_from_domain(host)
        return nil unless matching_string
        if selected_app = matching_string[1]
          dns_check(selected_app)
        else
          nil
        end
      end

      def dns_check(selected_app)
        Invoker::IPC::UnixClient.send_command("dns_check", process_name: selected_app) do |dns_check_response|
          dns_check_response
        end
      end

      def return_error_page(status)
        http_response = Invoker::Power::HttpResponse.new()
        http_response.status = status
        http_response['Content-Type'] = "text/html; charset=utf-8"
        http_response.use_file_as_body(File.join(File.dirname(__FILE__), "templates/#{status}.html"))
        connection.send_data(http_response.http_string)
      end
    end
  end
end
