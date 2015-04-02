require 'em-proxy'
require 'http-parser'
require "invoker/power/http_parser"
require "invoker/power/url_rewriter"

module Invoker
  module Power
    class InvokerHttpProxy < EventMachine::ProxyServer::Connection
      attr_accessor :host, :ip, :port
      def set_host(host, selected_backend)
        self.host = host
        self.ip = selected_backend[:host]
        self.port = selected_backend[:port]
      end
    end

    class InvokerHttpsProxy < InvokerHttpProxy
      def post_init
        super
        start_tls
      end
    end

    class Balancer
      attr_accessor :connection, :http_parser, :session, :protocol

      def self.run(options = {})
        start_http_proxy(InvokerHttpProxy, 'http', options)
        start_http_proxy(InvokerHttpsProxy, 'https', options)
      end

      def self.start_http_proxy(proxy_class, protocol, options)
        port = protocol == 'http' ? Invoker.config.http_port : Invoker.config.https_port
        EventMachine.start_server('0.0.0.0', port,
                                  proxy_class, options) do |connection|
          balancer = Balancer.new(connection, protocol)
          balancer.install_callbacks
        end
      end

      def initialize(connection, protocol)
        @connection = connection
        @protocol = protocol
        @http_parser = HttpParser.new(protocol)
        @session = nil
        @buffer = []
      end

      def install_callbacks
        http_parser.on_headers_complete { |headers| headers_received(headers) }
        http_parser.on_message_complete { |full_message| complete_message_received(full_message) }
        connection.on_data { |data| upstream_data(data) }
        connection.on_response { |backend, data| backend_data(backend, data) }
        connection.on_finish { |backend, name| frontend_disconnect(backend, name) }
      end

      def complete_message_received(full_message)
        connection.relay_to_servers(full_message)
        http_parser.reset
      end

      def headers_received(headers)
        if @session
          return
        end
        @session = UUID.generate()
        dns_check_response = UrlRewriter.new.select_backend_config(headers['Host'])
        if dns_check_response && dns_check_response.port
          connection.server(session, host: '0.0.0.0', port: dns_check_response.port)
        else
          return_error_page(404)
          http_parser.reset
          connection.close_connection_after_writing
        end
      end

      def upstream_data(data)
        append_for_http_parsing(data)
        nil
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
        http_parser.reset
        unless @backend_data
          return_error_page(503)
        end
        @backend_data = false
        connection.close_connection_after_writing if backend == session
      end

      private

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
