module Invoker
  class Reactor
    attr_accessor :read_array, :pending_writes

    def initialize
      @read_array = []
      @pending_writes = {}
    end

    def send_data(socket, data)
      unwritten_data = ""
      begin
        unwritten_data = low_level_write(socket, data)
      rescue
        remove_from_write_monitoring(socket)
      end
      unless unwritten_data.empty?
        @pending_writes[socket.fileno] = { data: unwritten_data, socket: socket }
      end
    end

    def watch_for_read(fd)
      @read_array << fd
    end

    def monitor_for_fd_events
      ready_read_fds, ready_write_fds, error_fds = select(*options_for_select)

      if ready_read_fds && !ready_read_fds.empty?
        handle_read_event(ready_read_fds)
      end

      if ready_write_fds && !ready_write_fds.empty?
        handle_write_event(ready_write_fds)
      end
    end

    private

    def handle_read_event(ready_read_fds)
      ready_fds = ready_read_fds.flatten.compact
      ready_fds.each { |ready_fd| process_read(ready_fd) }
    end

    def process_read(ready_fd)
      command_worker = Invoker.commander.get_worker_from_fd(ready_fd)
      begin
        data = read_data(ready_fd)
        command_worker.receive_data(data)
      rescue Invoker::Errors::ProcessTerminated
        remove_from_read_monitoring(command_worker.pipe_end, command_worker)
      end
    end

    def low_level_write(socket, data)
      data_string = data.to_s
      data_length = data.to_s
      begin
        written_length = socket.write_nonblock(data)
        return "" if written_length == data_length
        data_string[written_length..-1]
      rescue Errno::EAGAIN
        data_string
      end
    end

    def handle_write_event(ready_write_fds)
      write_fds = ready_write_fds.flatten.compact
      write_fds.each { |write_fd| process_write(ready_fd) }
    end

    def process_write(ready_fd)
      pending_object = @pending_writes[ready_fd.fileno]
      if pending_object
        send_data(pending_object[:socket], pending_object[:data])
      else
        remove_from_write_monitoring(ready_fd)
      end
    end

    def remove_from_read_monitoring(fd, command_worker)
      read_array.delete(fd)
      command_worker.unbind
    rescue StandardError => error
      Invoker::Logger.puts(error.message)
      Invoker::Logger.puts(error.backtrace)
    end

    def remove_from_write_monitoring(socket)
      @pending_writes.delete(socket.fileno)
      socket.close
    rescue StandardError => error
      Invoker::Logger.puts(error.message)
      Invoker::Logger.puts(error.backtrace)
    end

    def options_for_select
      write_array = pending_writes.map { |fd, pending_object| pending_object[:socket] }
      [read_array, write_array, [], 0.05]
    end

    def read_data(ready_fd)
      sock_data = []
      begin
        while(t_data = ready_fd.read_nonblock(64))
          sock_data << t_data
        end
      rescue Errno::EAGAIN
        return sock_data.join
      rescue Errno::EWOULDBLOCK
        return sock_data.join
      rescue
        raise Invoker::Errors::ProcessTerminated.new(ready_fd,sock_data.join)
      end
    end

  end
end
