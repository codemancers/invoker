require "fileutils"

module Invoker
  module IPC
    class Server
      SOCKET_PATH = "/tmp/invoker"
      def initialize
        @open_clients = []
        Socket.unix_server_loop(SOCKET_PATH) do |sock, client_addrinfo|
          Thread.new { process_client(sock) }
        end
      end

      def clean_old_socket
        if File.exist?(SOCKET_PATH)
          FileUtils.rm(SOCKET_PATH, :force => true)
        end
      end

      def process_client(client_socket)
        client = Invoker::IPC::ClientHandler.new(client_socket)
        client.read_and_execute
      rescue StandardError => error
        Invoker::Logger.puts error.message
        Invoker::Logger.puts error.backtrace
      ensure
        client_socket.close
      end
    end
  end
end
