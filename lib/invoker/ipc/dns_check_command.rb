module Invoker
  module IPC
    class DnsCheckCommand < BaseCommand
      def run_command(message_object)
        process_detail = Invoker.dns_cache[message_object.process_name]

        dns_check_response = Invoker::IPC::Message::DnsCheckResponse.new(
          process_name: message_object.process_name,
          port: process_detail ? process_detail['port'] : nil,
          ip: process_detail && process_detail['ip'] ? process_detail['ip'] : '0.0.0.0'
        )
        send_data(dns_check_response)
        true
      end
    end
  end
end
