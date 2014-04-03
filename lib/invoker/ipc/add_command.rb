module Invoker
  module IPC
    class AddCommand < BaseCommand
      def run_command(message_object)
        Invoker.commander.on_next_tick(message_object.process_name) do |process_name|
          add_command_by_label(process_name)
        end
      end
    end
  end
end
