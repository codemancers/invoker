module Necro
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
      # $stdout.print(".")
    end

    # Print the lines received over the network
    def receive_line(line)
      $stdout.puts "#{@command_label.send(color)} : #{line}"
    end
  end
end
