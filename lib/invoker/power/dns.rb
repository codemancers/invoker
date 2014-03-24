require "logger"
require 'rubydns'

module Invoker
  module Power
    class DNS < RubyDNS::Server
      def self.server_ports
        [
          [:udp, '127.0.0.1', Invoker::CONFIG.dns_port],
          [:tcp, '127.0.0.1', Invoker::CONFIG.dns_port]
        ]
      end

      def process(name, resource_class, transaction)
        if name_matches?(name) && resource_class_matches?(resource_class)
          transaction.respond!("127.0.0.1")
        else
          transaction.fail!(:NXDomain)
        end
      end

      private

      def resource_class_matches?(resource_class)
        resource_class == Resolv::DNS::Resource::IN::A
      end

      def name_matches?(name)
        name =~ /.*\.dev/
      end
    end
  end
end
