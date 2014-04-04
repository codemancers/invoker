module Invoker
  module IPC
    class DnsCheckCommand < BaseCommand
      def run_command(message_object)
        process_detail = Invoker.dns_cache[message_object.process_name]

        dns_check_response = Invoker::IPC::Message::DnsCheckResponse.new(
          process_name: message_object.process_name,
          port: process_detail ? process_detail['port'] : nil
        )
        send_data(dns_check_response)
      end
    end
  end
end
