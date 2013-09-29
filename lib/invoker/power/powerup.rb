require 'eventmachine'
require 'rubydns'
require 'http/parser'
require 'em-proxy'
require 'power/dns'
require 'power/balancer'

module Invoker
  module Power
    class Powerup
      def self.fork_and_start
        powerup = new()
        fork { powerup.run }
      end

      def run
        EM.epoll
        EM.run {
          term("TERM") { stop }
          term("INT") { stop }
          DNS.run_dns()
          Balancer.run()
        }
      end

      def stop
        Invoker::Logger.puts "Terminating Proxy/Server"
        EventMachine.stop
      end
    end
  end
end
