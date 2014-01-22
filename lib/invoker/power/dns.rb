require "logger"

module Invoker
  module Power
    class DNS
      IN = Resolv::DNS::Resource::IN
      def self.server_ports
        [
          [:udp, '127.0.0.1', Invoker::CONFIG.dns_port],
          [:tcp, '127.0.0.1', Invoker::CONFIG.dns_port]
        ]
      end

      def self.run_dns
        RubyDNS::run_server(:listen => server_ports) do
          on(:start) do
            @logger.level = ::Logger::WARN
          end

          # For this exact address record, return an IP address
          match(/.*\.dev/, IN::A) do |transaction|
            transaction.respond!("127.0.0.1")
          end

          # Default DNS handler
          otherwise do |transaction|
            transaction.failure!(:NXDomain)
          end
        end
      end
    end
  end
end
