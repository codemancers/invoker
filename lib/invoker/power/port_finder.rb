module Invoker
  module Power
    class PortFinder
      STARTING_PORT = 23400
      attr_accessor :dns_port, :http_port, :starting_port, :https_port
      def initialize
        @starting_port = STARTING_PORT
        @ports = []
        @dns_port = nil
        @http_port = nil
      end

      def find_ports
        STARTING_PORT.upto(STARTING_PORT + 100) do |port|
          break if @ports.size > 3
          if check_if_port_is_open(port)
            @ports << port
          else
            next
          end
        end
        @dns_port = @ports[0]
        @http_port = @ports[1]
        @https_port = @ports[2]
      end

      private

      def check_if_port_is_open(port)
        socket_flag = true
        sockets = nil
        begin
          sockets = Socket.tcp_server_sockets(port)
          socket_flag = false if sockets.size <= 1
        rescue Errno::EADDRINUSE
          socket_flag = false
        end
        sockets && close_socket_pairs(sockets)
        socket_flag
      end

      def close_socket_pairs(sockets)
        sockets.each { |s| s.close }
      rescue
        nil
      end
    end
  end
end
