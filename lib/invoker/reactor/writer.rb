module Invoker
  class Reactor::Writer
    attr_accessor :pending_writes
    def initialize
      @pending_writes = {}
    end

    def handle_write_event(ready_write_fds)
      write_fds = ready_write_fds.flatten.compact
      write_fds.each { |write_fd| process_write(write_fd) }
    end

    def send_data(socket, data)
      unwritten_data = ""

      begin
        unwritten_data = low_level_write(socket, data)
      rescue
        remove_from_write_monitoring(socket)
        raise Invoker::Errors::ClientDisconnected
      end
      schedule_for_monitoring(socket, unwritten_data) unless unwritten_data.empty?
    end

    def write_array
      @pending_writes.map { |_, pending_object| pending_object[:socket] }
    end

    private

    def process_write(write_ready_fd)
      pending_object = @pending_writes.delete(write_ready_fd.fileno)

      if pending_object
        send_and_rescue(pending_object[:socket], pending_object[:data])
      end
    end

    def send_and_rescue(socket, data)
      send_data(socket, data)
    rescue Invoker::Errors::ClientDisconnected
      Invoker.close_socket(socket)
    end

    def low_level_write(socket, data)
      data_string = data.to_s
      data_length = data.to_s
      begin
        written_length = socket.write_nonblock(data)
        return "" if written_length == data_length
        data_string[written_length..-1]
      rescue IO::WaitWritable, Errno::EINTR, Errno::EAGAIN
        data_string
      end
    end

    def schedule_for_monitoring(socket, data)
      Invoker.puts "Scheduling data for delayed write #{socket}".color(:red)
      @pending_writes[socket.fileno] = { data: data, socket: socket }
    end

    def remove_from_write_monitoring(socket)
      @pending_writes.delete(socket.fileno)
    rescue
      Invoker::Logger.puts "Error Removing #{socket.inspect} from write monitoring".color(:red)
    end
  end
end
