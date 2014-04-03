module Invoker
  class CommandWorker
    attr_accessor :command_label, :pipe_end, :pid, :color
    attr_accessor :reactor

    def initialize(command_label, pipe_end, pid, color, reactor)
      @reactor = reactor
      @command_label = command_label
      @pipe_end = pipe_end
      @pid = pid
      @color = color
    end

    # Copied verbatim from Eventmachine code
    def receive_data data
      (@buf ||= '') << data

      while @buf.slice!(/(.*?)\r?\n/)
        receive_line($1)
      end
    end

    def unbind
      Invoker::Logger.print(".")
    end

    # Print the lines received over the network
    def receive_line(line)
      tail_watchers = Invoker.tail_watcher[@command_label]
      colored_line = "#{@command_label.color(color)} : #{line}"
      if tail_watchers && !tail_watchers.empty?
        tail_watchers.each { |tail_socket| send_data(tail_socket, colored_line) }
      else
        Invoker::Logger.puts colored_line
      end
    end

    def to_h
      { command_label:  command_label, pid:  pid.to_s }
    end

    def send_data(socket, data)
      # Unlike regular write ensures that data is written in a nonblocking fashion
      reactor.send_data(socket, data)
    end
  end
end
