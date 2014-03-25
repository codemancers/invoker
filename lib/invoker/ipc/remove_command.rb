module Invoker
  module IPC
    class RemoveCommand < BaseCommand
      def run_command(message_object)
        Invoker::COMMANDER.on_next_tick(message_object) do |remove_message|
          remove_command(remove_message)
        end
      end
    end
  end
end
