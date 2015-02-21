module Invoker
  module IPC
    class RemoveCommand < BaseCommand
      def run_command(remove_message)
        Invoker.commander.on_next_tick(remove_message) do |remove_message|
          process_or_group_name = remove_message.process_name
          stop_process_or_group_by_name(process_or_group_name, stop_signal: remove_message.signal)
        end

        true
      end
    end
  end
end
