module Invoker

  module Power

    class DNS
      IN = Resolv::DNS::Resource::IN
      SERVER_PORTS = [[:udp, '127.0.0.1', 23400], [:tcp, '127.0.0.1', 23400]]

      def self.run_dns
        RubyDNS::run_server(:listen => SERVER_PORTS) do
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
