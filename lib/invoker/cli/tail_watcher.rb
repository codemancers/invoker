module Invoker
  # This class defines sockets which are open for watching log files
  class CLI::TailWatcher
    attr_accessor :tail_watchers

    def initialize
      @tail_mutex = Mutex.new
      @tail_watchers = Hash.new { |h, k| h[k] = [] }
    end

    def [](process_name)
      @tail_mutex.synchronize { tail_watchers[process_name] }
    end

    def add(names, socket)
      @tail_mutex.synchronize do
        names.each { |name| tail_watchers[name] << socket }
      end
    end

    def remove(name, socket)
      @tail_mutex.synchronize do
        client_list = tail_watchers[name]
        client_list.delete(socket)
        purge(name, socket) if client_list.empty?
      end
    end

    def purge(name, socket)
      tail_watchers.delete(name)
      Invoker.close_socket(socket)
    end
  end
end
