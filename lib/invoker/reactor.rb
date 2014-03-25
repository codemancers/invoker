module Invoker
  class Reactor
    attr_accessor :monitored_fds
    def initialize
      @monitored_fds = []
    end

    def add_to_monitor(fd)
      @monitored_fds << fd
    end

    def remove_from_monitoring(fd, command_worker)
      @monitored_fds.delete(fd)
      command_worker.unbind
    rescue StandardError => error
      Invoker::Logger.puts(error.message)
      Invoker::Logger.puts(error.backtrace)
    end

    def watch_on_pipe
      ready_read_fds,ready_write_fds,read_error_fds = select(monitored_fds,[],[],0.05)

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
        remove_from_monitoring(command_worker.pipe_end, command_worker)
      end
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
