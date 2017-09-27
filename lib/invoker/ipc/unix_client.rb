module Invoker
  module IPC
    class UnixClient
      def send_command(command, message = {})
        message_object = get_message_object(command, message)
        open_client_socket do |socket|
          send_json_message(socket, message_object)
          socket.flush
          if block_given?
            response_object = Invoker::IPC.message_from_io(socket)
            yield response_object
          end
        end
      end

      def send_and_receive(command, message = {})
        response = nil
        message_object = get_message_object(command, message)
        open_client_socket(false) do |socket|
          send_json_message(socket, message_object)
          socket.flush
          response = Invoker::IPC.message_from_io(socket)
        end
        response
      end

      def send_and_wait(command, message = {})
        begin
          socket = Socket.unix(Invoker::IPC::Server::SOCKET_PATH)
        rescue
          abort("Invoker does not seem to be running".colorize(:red))
        end
        message_object = get_message_object(command, message)
        send_json_message(socket, message_object)
        socket.flush
        socket
      end

      def self.send_command(command, message_arguments = {}, &block)
        new.send_command(command, message_arguments, &block)
      end

      private

      def get_message_object(command, message_arguments)
        Invoker::IPC::Message.const_get(Invoker::IPC.camelize(command)).new(message_arguments)
      end

      def open_client_socket(abort_if_not_running = true)
        Socket.unix(Invoker::IPC::Server::SOCKET_PATH) { |socket| yield socket }
      rescue
        abort_if_not_running && abort("Invoker does not seem to be running".colorize(:red))
      end

      def send_json_message(socket, message_object)
        socket.write(message_object.encoded_message)
      end
    end
  end
end
