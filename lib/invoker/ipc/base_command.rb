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

      def run_command(message_object)
        raise "Not implemented"
      end
    end
  end
end
