require "fileutils"

module Invoker
  module CommandListener
    class Server
      SOCKET_PATH = "/tmp/invoker"
      def initialize
        @open_clients = []
        Socket.unix_server_loop(SOCKET_PATH) {|sock, client_addrinfo|
          begin
            process_client(sock)
          ensure
            sock.close
          end
        }
      end

      def clean_old_socket
        if File.exists?(SOCKET_PATH)
          FileUtils.rm(SOCKET_PATH, :force => true)
        end
      end

      def process_client(client_socket)
        client = Invoker::CommandListener::Client.new(client_socket)
        client.read_and_execute
      end
    end
  end

end
