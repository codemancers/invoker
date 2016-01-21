require "invoker/power/http_response"
require "invoker/power/dns"
require "invoker/power/balancer"

require "invoker/power/tld"

module Invoker
  module Power
    class << self
      attr_writer :tld_value

      def reset_tld_value
        @tld_value = nil
      end

      def tld
        tld_value = @tld_value
        if !tld_value && Invoker.config
          tld_value = Invoker.config.tld
        end
        Tld.new(tld_value)
      end

      def tld_value
        tld.value
      end
    end
  end
end
