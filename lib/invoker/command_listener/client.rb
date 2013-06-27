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
          worker_command.strip!
          if worker_command
            run_command(worker_command, command_label, rest_args)
          end
        end
      end

      def run_command(worker_command, command_label, rest_args = nil)
        case worker_command
        when 'add'
          Invoker::COMMANDER.on_next_tick(command_label) { |b_command_label|
            add_command_by_label(b_command_label)
          }
        when 'list'
          json = Invoker::COMMANDER.list_commands()
          puts "Writing data #{json.inspect}"
        when 'remove'
          Invoker::COMMANDER.on_next_tick(command_label, rest_args) { |b_command_label,b_rest_args|
            remove_command(b_command_label, b_rest_args)
          }
        when 'reload'
          Invoker::COMMANDER.on_next_tick(command_label, rest_args) { |b_command_label, b_rest_args|
            reload_command(b_command_label, b_rest_args)
          }
        else
          Invoker::Logger.puts("\n Invalid command".red)
        end
      end
    end
  end
end
