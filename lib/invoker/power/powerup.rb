module Invoker
  # power is really a stupid pun on pow.
  module Power
    class Powerup
      def self.fork_and_start
        powerup = new()
        fork { powerup.run }
      end

      def run
        require "invoker/power/power"
        EM.epoll
        EM.run do
          trap("TERM") { stop }
          trap("INT") { stop }
          RubyDNS.run_server(dns_options) if Invoker.darwin?
          Balancer.run
        end
      end

      def stop
        Invoker::Logger.puts "Terminating Proxy/Server"
        EventMachine.stop
      end

      private

      def dns_options
        {
          asynchronous: true,
          server_class: Invoker::Power::DNS,
          listen: DNS.server_ports
        }
      end
    end
  end
end
