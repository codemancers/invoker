module Invoker
  module IPC
    class TailCommand < BaseCommand
      def run_command(message_object)
        Invoker::WORKER_LISTENER.add(client_socket, message_object.process_name)
      end
    end
  end
end
