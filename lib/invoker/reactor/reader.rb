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
      begin
        data = read_data(ready_fd)
        send_data_to_worker(data, command_worker)
      rescue Invoker::Errors::ProcessTerminated
        remove_from_read_monitoring(command_worker, ready_fd)
      end
    end

    def send_data_to_worker(data, command_worker)
      if command_worker
        command_worker.receive_data(data)
      else
        Invoker::Logger.puts("No reader found for incoming data")
      end
    end

    def remove_from_read_monitoring(command_worker, ready_fd)
      if command_worker
        read_array.delete(command_worker.pipe_end)
        command_worker.unbind
      else
        read_array.delete(ready_fd)
      end
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
