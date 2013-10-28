module Invoker
  class ProcessManager
    attr_accessor :process_id, :signal
    def initialize(pid, signal)
      @process_id = pid
      @signal = signal
      @error_flag = true
    end

    # Given a process id, kill the process and all its children
    def kill
      children_pids = children()
      children_pids.each do |child_pid|
        process_kill(child_pid)
        error_flag = false
      end
    end


    private
    def children
      children_pids = []
      process_array = `ps -o pid,ppid -ax`.split("\n").map { |x| x.split }
      process_array.each do |pid, ppid|
        if pid =~ /\d+/ && ppid =~ /\d+/ && is_child?(ppid.to_i)
          children_pids << pid.to_i
        end
      end
      children_pids
    end

    def process_kill(pid_to_kill)
    end

    def is_child?(ppid)
      ppid == process_id
    end
  end
end
