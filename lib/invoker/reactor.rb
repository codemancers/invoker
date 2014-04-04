module Invoker
  class Reactor
    attr_accessor :reader, :writer

    def initialize
      @reader = Invoker::Reactor::Reader.new
      @writer = Invoker::Reactor::Writer.new
    end

    def watch_for_read(fd)
      reader.watch_for_read(fd)
    end

    def send_data(socket, data)
      writer.send_data(socket, data)
    rescue Invoker::Errors::ClientDisconnected
      socket.close
    end

    def monitor_for_fd_events
      ready_read_fds, ready_write_fds, _ = select(*options_for_select)

      if ready_read_fds && !ready_read_fds.empty?
        reader.handle_read_event(ready_read_fds)
      end

      if ready_write_fds && !ready_write_fds.empty?
        writer.handle_write_event(ready_write_fds)
      end
    end

    private

    def options_for_select
      [reader.read_array, write.write_array, [], 0.05]
    end
  end
end

require "invoker/reactor/reader"
require "invoker/reactor/writer"
