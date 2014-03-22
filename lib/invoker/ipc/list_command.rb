module Invoker
  module IPC
    class ListCommand < BaseCommand
      def run_command(message_object)
        list_response = Invoker::COMMANDER.process_list
        send_data(list_response)
      end
    end
  end
end
