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

    def add(name, socket)
      @tail_mutex.synchronize { tail_watchers[name] << socket }
    end

    def remove(name, socket)
      @tail_mutex.synchronize do
        client_list = tail_watchers[name]
        client_list.delete(socket)
        tail_watchers.delete(name) if client_list.empty?
      end
    end
  end
end
