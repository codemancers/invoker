module Invoker
  module IPC
    class TailCommand < BaseCommand
      def run_command(message_object)
        Invoker::Logger.puts("Adding #{message_object.process_names.inspect}")
        Invoker.tail_watchers.add(message_object.process_names, client_socket)
        false
      end
    end
  end
end
