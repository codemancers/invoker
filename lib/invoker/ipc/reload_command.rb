module Invoker
  module IPC
    class ReloadCommand < BaseCommand
      def run_command(reload_message)
        Invoker.commander.on_next_tick(reload_message) do |reload_message|
          process_or_group_name = reload_message.process_name
          restart_process_or_group_by_name(process_or_group_name, stop_signal: reload_message.signal)
        end

        true
      end
    end
  end
end
