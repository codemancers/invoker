module Invoker
  module Power
    module ProxyConnectionExtension
      def self.extended(connection)
        class << connection
          attr_accessor :host_known, :host, :ip, :port
        end
      end

      def set_host(host, selected_backend)
        self.host = host
        self.ip = selected_backend[:host]
        self.port = selected_backend[:port]
        self.host_known = true
      end
    end

    class Balancer

    end
  end
end
