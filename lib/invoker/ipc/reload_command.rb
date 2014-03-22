module Invoker
  module IPC
    class ReloadCommand < BaseCommand
      def run_command
        Invoker::COMMANDER.on_next_tick(message_object) do |reload_message|
          reload_command(reload_message)
        end
      end
    end
  end
end
