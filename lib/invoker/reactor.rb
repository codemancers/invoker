module Invoker
  class Reactor
    attr_accessor :reader

    def initialize
      @reader = Invoker::Reactor::Reader.new
    end

    def watch_for_read(fd)
      reader.watch_for_read(fd)
    end

    # Writes data to client socket and raises error if errors
    # while writing
    def send_data(socket, data)
      socket.write(data)
    rescue
      raise Invoker::Errors::ClientDisconnected
    end

    def monitor_for_fd_events
      ready_read_fds, _ , _ = select(*options_for_select)

      if ready_read_fds && !ready_read_fds.empty?
        reader.handle_read_event(ready_read_fds)
      end
    end

    private

    def options_for_select
      [reader.read_array, [], [], 0.05]
    end
  end
end

require "invoker/reactor/reader"
