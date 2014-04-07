module Invoker
  class CLI::Tail
    attr_accessor :process_names
    def initialize(process_names)
      verify_process_name(process_names)
      @process_names = process_names
      @unix_socket = Invoker::IPC::UnixClient.new
    end

    def run
      socket = @unix_socket.send_and_wait('tail', process_names: process_names)
      trap('INT') { socket.close }
      loop do
        message = read_next_line(socket)
        break unless message
        puts message.tail_line
      end
    end

    private

    def verify_process_name(process_names)
      if process_names.empty?
        abort("Tail command requires one or more process name")
      end
    end

    def read_next_line(socket)
      Invoker::IPC.message_from_io(socket)
    rescue
      nil
    end
  end
end
