module Invoker
  module IPC
    class AddCommand < BaseCommand
      def run_command(message_object)
        Invoker.commander.on_next_tick(message_object.process_name) do |process_or_group_name|
          start_process_or_group_by_name(process_or_group_name)
        end

        true
      end
    end
  end
end
