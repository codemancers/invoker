module Invoker
  class Reactor
    attr_accessor :write_array, :read_array

    def initialize
      @write_array = []
      @read_array = []
    end

    def watch_for_write(fd)
      @write_array << fd
    end

    def watch_for_read(fd)
      @read_array << fd
    end

    def monitor_for_fd_events
      ready_read_fds,ready_write_fds,read_error_fds = select(options_for_select)
      if ready_read_fds && !ready_read_fds.empty?
        handle_read_event(ready_read_fds)
      end
    end

    def handle_read_event(ready_read_fds)
      ready_fds = ready_read_fds.flatten.compact
      ready_fds.each {|ready_fd| process_read(ready_fd) }
    end

    def process_read(ready_fd)
      command_worker = Invoker::COMMANDER.get_worker_from_fd(ready_fd)
      begin
        data = read_data(ready_fd)
        command_worker.receive_data(data)
      rescue Invoker::Errors::ProcessTerminated
        remove_from_read_monitoring(command_worker.pipe_end, command_worker)
      end
    end

    private

    def remove_from_read_monitoring(fd, command_worker)
      read_array_array.delete(fd)
      command_worker.unbind
    rescue StandardError => error
      Invoker::Logger.puts(error.message)
      Invoker::Logger.puts(error.backtrace)
    end


    def options_for_select
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
