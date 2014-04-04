module Invoker
  module IPC
    class TailCommand < BaseCommand
      def run_command(message_object)
        Invoker.tail_watchers.add(message_object.process_name, client_socket)
        false
      end
    end
  end
end
