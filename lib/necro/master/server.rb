require "fileutils"

module Necro
  module Master
    class Server
      SOCKET_PATH = "/tmp/necro"
      def initialize
        @open_clients = []
        clean_old_socket()
        UNIXServer.open(SOCKET_PATH) do |client|
          loop do
            client_socket = client.accept
            process_client(client_socket)
          end
        end
      end

      def clean_old_socket
        if File.exists?(SOCKET_PATH)
          FileUtils.rm(SOCKET_PATH, :force => true)
        end
      end

      def process_client(client_socket)
        client = Necro::Master::Client.new(client_socket)
        client.read_and_execute
      end
    end
  end

end
