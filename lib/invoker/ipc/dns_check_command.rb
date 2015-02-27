module Invoker
  module IPC
    class DnsCheckCommand < BaseCommand
      def run_command(message_object)
        process_detail = Invoker.dns_cache.find_process(message_object.host, message_object.path)

        dns_check_response = Invoker::IPC::Message::DnsCheckResponse.new(process_detail || {})
        send_data(dns_check_response)
        true
      end
    end
  end
end
