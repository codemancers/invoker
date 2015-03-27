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
          if Invoker.darwin?
            RubyDNS.run_server(asynchronous: true, server_class: Invoker::Power::DNS)
          end
          Balancer.run
        end
      end

      def stop
        Invoker::Logger.puts "Terminating Proxy/Server"
        EventMachine.stop
      end
    end
  end
end
