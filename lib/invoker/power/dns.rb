require "logger"
require 'rubydns'

module Invoker
  module Power
    class DNS < RubyDNS::Server
      def self.server_ports
        [
          [:udp, '127.0.0.1', Invoker.config.dns_port],
          [:tcp, '127.0.0.1', Invoker.config.dns_port]
        ]
      end

      def initialize
        @logger = ::Logger.new($stderr)
        @logger.level = ::Logger::FATAL
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
        name =~ /.*\.#{Invoker::Power.tld_value}/
      end
    end
  end
end
