require 'power/dns'
require 'power/balancer'

module Invoker
  module Power
    class Powerup
      def self.run
        EM.epoll
        EM.run {
          term("TERM") { stop }
          term("INT") { stop }
          DNS.run_dns()
        }
      end

      def self.stop
        puts "Terminating Proxy/Server"
        EventMachine.stop
      end
    end
  end
end
