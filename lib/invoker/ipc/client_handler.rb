module Invoker
  module IPC
    class ClientHandler
      attr_accessor :client_socket
      def initialize(client_socket)
        @client_socket = client_socket
      end

      def read_and_execute
        client_handler, message_object = read_incoming_command
        client_socket.close if client_handler.run_command(message_object)
      rescue StandardError => error
        Invoker::Logger.puts error.message
        Invoker::Logger.puts error.backtrace
        client_socket.close
      end

      private

      def read_incoming_command
        message_object = Invoker::IPC.message_from_io(client_socket)
        [message_object.command_handler_klass.new(client_socket), message_object]
      end
    end
  end
end
