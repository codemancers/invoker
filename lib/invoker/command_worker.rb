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
      tail_watchers = Invoker.tail_watchers[@command_label]
      if tail_watchers && !tail_watchers.empty?
        tail_response = Invoker::IPC::Message::TailResponse.new(tail_line: line)
        json_response = tail_response.encoded_message
        tail_watchers.each { |tail_socket| send_data(tail_socket, json_response) }
      else
        Invoker::Logger.puts "#{@command_label.color(color)} : #{line}"
      end
    end

    def to_h
      { command_label:  command_label, pid:  pid.to_s }
    end

    def send_data(socket, data)
      # Unlike regular write ensures that data is written in a nonblocking fashion
      reactor.send_data(socket, data)
    rescue Invoker::Errors::ClientDisconnected
      Invoker::Logger.puts "Removing #{@command_label} watcher #{socket} from list"
      Invoker.tail_watchers.remove(@command_label, socket)
      Invoker.close_socket(socket)
    end
  end
end
