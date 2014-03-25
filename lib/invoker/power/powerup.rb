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
        EM.run {
          trap("TERM") { stop }
          trap("INT") { stop }
          DNS.new.run(listen: DNS.server_ports)
          Balancer.run
        }
      end

      def stop
        Invoker::Logger.puts "Terminating Proxy/Server"
        EventMachine.stop
      end
    end
  end
end
