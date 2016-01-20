require "invoker/power/http_response"
require "invoker/power/dns"
require "invoker/power/balancer"

module Invoker
  module Power
    class << self
      attr_writer :tld

      def tld
        return @tld if @tld
        return Invoker.config.tld if Invoker.config && Invoker.config.tld
        default_tld
      end

      def reset_tld
        @tld = nil
      end

      private

      def default_tld
        'dev'
      end 
    end
  end
end
