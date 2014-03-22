module Invoker
  module IPC
    class BaseCommand
      attr_accessor :client_socket
      def initialize(client_socket)
        @client_socket = client_socket
      end

      def send_data(message_object)
        Yajl::Encoder.encode(message_object.as_json, client_socket)
      end

      def run_command(message_object)
        raise "Not implemented"
      end
    end
  end
end
