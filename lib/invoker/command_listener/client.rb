module Invoker
  module CommandListener
    class Client
      attr_accessor :client_socket
      def initialize(client_socket)
        @client_socket = client_socket
      end

      def read_and_execute
        command_info = client_socket.read()
        if command_info && !command_info.empty?
          worker_command, command_label, rest_args = command_info.strip.split(" ")
          if worker_command && command_label
            run_command(worker_command, command_label, rest_args)
          end
        end
        client_socket.close()
      end

      def run_command(worker_command, command_label, rest_args = nil)
        case worker_command
        when 'add'
          Invoker::COMMANDER.add_command_by_label(command_label)
        when 'list'
          Invoker::COMMANDER.list_commands()
        when 'remove'
          Invoker::COMMANDER.remove_command(command_label, rest_args)
        when 'reload'
          Invoker::COMMANDER.reload_command(command_label, rest_args)
        else
          Invoker::Logger.puts("\n Invalid command".red)
        end
      end
    end
  end
end
