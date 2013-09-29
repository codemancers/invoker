module Invoker
  module Power
    class DNS
      IN = Resolv::DNS::Resource::IN
      def self.run_dns
        server = RubyDNS::Server.new(&block)
        server.logger.info "Starting RubyDNS server (v#{RubyDNS::VERSION})..."

        options = {}
        options[:listen] = [[:udp, '127.0.0.1', 23400], [:tcp, '127.0.0.1', 23400]]
        server.fire(:setup)

        # Setup server sockets
        options[:listen].each do |spec|
          server.logger.info "Listening on #{spec.join(':')}"
          if spec[0] == :udp
            EventMachine.open_datagram_socket(spec[1], spec[2], UDPHandler, server)
          elsif spec[0] == :tcp
            EventMachine.start_server(spec[1], spec[2], TCPHandler, server)
          end
        end
        server.fire(:start)
      end
    end
  end
end
