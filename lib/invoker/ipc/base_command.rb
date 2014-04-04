module Invoker
  module IPC
    class BaseCommand
      attr_accessor :client_socket
      def initialize(client_socket)
        @client_socket = client_socket
      end

      def send_data(message_object)
        client_socket.write(message_object.encoded_message)
      end

      # Invoke the command that actual processes incoming message
      # returning true from this message means, command has been processed
      # and client socket can be closed. returning false means, it is a
      # long running command and socket should not be closed immediately
      # @param [Invoker::IPC::Message] incoming message
      # @return [Boolean] true or false
      def run_command(message_object)
        raise "Not implemented"
      end
    end
  end
end
