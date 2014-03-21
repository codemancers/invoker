module Invoker
  class CLI
    class Connection
      def send_command(command, message = {})
        message_object = get_message_object(command, message)
        open_client_socket do |socket|
          send_json_message(socket, message_object)
          if block_given?
            response_object = Invoker::IPC.message_from_io(socket)
            yield response_object
          end
        end
      end

      private

      def get_message_object(command, message_arguments)
        Invoker::IPC.const_get(command.camelize).new(message_arguments)
      end

      def open_client_socket
        Socket.unix(Invoker::IPC::Server::SOCKET_PATH) do |socket|
          yield socket
          socket.flush
        end
      end

      def send_json_message(socket, message_object)
        Yajl::Encoder.encode(message_object.as_json, socket)
      end
    end
  end
end
