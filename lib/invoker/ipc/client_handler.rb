module Invoker
  module IPC
    class ClientHandler
      attr_accessor :client_socket
      def initialize(client_socket)
        @client_socket = client_socket
      end

      def read_and_execute
        message_object = Invoker::IPC.message_from_io(client_socket)
        client_handler = message_object.command_handler_klass.new(client_socket)
        client_handler.run_command(message_object)
      end
    end
  end
end
