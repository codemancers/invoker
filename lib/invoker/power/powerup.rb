require 'power/dns'
require 'power/balancer'

module Invoker
  module Power
    class Powerup
      def self.run
        EM.run {
          DNS.run_dns()
        }
      end
    end
  end
end
