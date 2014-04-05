module Invoker
  module IPC
    class ReloadCommand < BaseCommand
      def run_command(message_object)
        Invoker.commander.on_next_tick(message_object) do |reload_message|
          reload_command(reload_message)
        end
        true
      end
    end
  end
end
