module Invoker
  module IPC
    class RemoveCommand < BaseCommand
      def run_command(message_object)
        Invoker.commander.on_next_tick(message_object) do |remove_message|
          stop_process(remove_message)
        end
        true
      end
    end
  end
end
