module Invoker
  module IPC
    class AddHttpCommand < BaseCommand
      def run_command(message_object)
        Invoker::DNS_CACHE.add(message_object.process_name, message_object.port)
      end
    end
  end
end
