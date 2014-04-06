module Invoker
  class CommandWorker
    attr_accessor :command_label, :pipe_end, :pid, :color

    def initialize(command_label, pipe_end, pid, color)
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
      color_line = "#{@command_label.color(color)} : #{line}"
      if tail_watchers && !tail_watchers.empty?
        tail_response = Invoker::IPC::Message::TailResponse.new(tail_line: color_line)
        json_response = tail_response.encoded_message
        tail_watchers.each { |tail_socket| send_data(tail_socket, json_response) }
      else
        Invoker::Logger.puts color_line
      end
    end

    def to_h
      { command_label:  command_label, pid:  pid.to_s }
    end

    def send_data(socket, data)
      socket.write(data)
    rescue
      Invoker::Logger.puts "Removing #{@command_label} watcher #{socket} from list"
      Invoker.tail_watchers.remove(@command_label, socket)
    end
  end
end
