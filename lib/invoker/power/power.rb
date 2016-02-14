require "invoker/power/http_response"
require "invoker/power/dns"
require "invoker/power/balancer"

module Invoker
  module Power
    class << self
      def set_tld(tld_value)
        @tld_value = tld_value
      end

      def reset_tld
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
