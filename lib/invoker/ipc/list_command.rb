module Invoker
  module IPC
    class ListCommand < BaseCommand
      def run_command(message_object)
        list_response = Invoker.commander.process_list
        send_data(list_response)
        true
      end
    end
  end
end
