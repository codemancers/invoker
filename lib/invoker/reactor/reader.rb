module Invoker
  class Reactor::Reader
    attr_accessor :read_array

    def initialize
      @read_array = []
    end

    def watch_for_read(socket)
      @read_array << socket
    end

    def handle_read_event(read_ready_fds)
      ready_fds = read_ready_fds.flatten.compact
      ready_fds.each { |ready_fd| process_read(ready_fd) }
    end

    private

    def process_read(ready_fd)
      command_worker = Invoker.commander.get_worker_from_fd(ready_fd)
      return unless command_worker
      begin
        data = read_data(ready_fd)
        command_worker.receive_data(data)
      rescue Invoker::Errors::ProcessTerminated
        remove_from_read_monitoring(command_worker.pipe_end, command_worker)
      end
    end

    def remove_from_read_monitoring(fd, command_worker)
      read_array.delete(fd)
      command_worker.unbind
    rescue StandardError => error
      Invoker::Logger.puts(error.message)
      Invoker::Logger.puts(error.backtrace)
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
