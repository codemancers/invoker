module Invoker
  class CLI::Tail
    attr_accessor :process_name
    def initialize(process_name)
      @process_name = process_name
      @unix_socket = Invoker::IPC::UnixClient.new()
    end

    def run
      socket = @unix_socket.send_and_wait('tail', process_name: process_name)
      trap('INT') { socket.close }
      loop do
        message = read_next_line(socket)
        break unless message
        puts message.tail_line
      end
    end

    private

    def read_next_line(socket)
      Invoker::IPC.message_from_io(socket)
    rescue
      nil
    end
  end
end
