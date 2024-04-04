module Invoker
  # rip off from borg
  # https://github.com/code-mancers/borg/blob/master/lib/borg/borg_daemon.rb
  class Daemon
    attr_reader :process_name

    def initialize
      @process_name = 'invoker'
    end

    def start
      if running?
        Invoker::Logger.puts "Invoker daemon is already running"
        exit(0)
      elsif dead?
        File.delete(pid_file) if File.exist?(pid_file)
      end
      Invoker::Logger.puts "Running Invoker daemon"
      daemonize
    end

    def stop
      kill_process
    end

    def pid_file
      File.join(Invoker.home, ".invoker", "#{process_name}.pid")
    end

    def pid
      File.read(pid_file).strip.to_i
    end

    def log_file
      File.join(Invoker.home, ".invoker", "#{process_name}.log")
    end

    def daemonize
      if fork
        sleep(2)
        exit(0)
      else
        Process.setsid
        File.open(pid_file, "w") do |file|
          file.write(Process.pid.to_s)
        end
        Invoker::Logger.puts "Invoker daemon log is available at #{log_file}"
        redirect_io(log_file)
        $0 = process_name
      end
    end

    def kill_process
      pgid =  Process.getpgid(pid)
      Process.kill('-TERM', pgid)
      File.delete(pid_file) if File.exist?(pid_file)
      Invoker::Logger.puts "Stopped Invoker daemon"
    end

    def process_running?
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    end

    def status
      @status ||= check_process_status
    end

    def pidfile_exists?
      File.exist?(pid_file)
    end

    def running?
      status == 0
    end

    # pidfile exists but process isn't running
    def dead?
      status == 1
    end

    private

    def check_process_status
      if pidfile_exists? && process_running?
        0
      elsif pidfile_exists? # but not process_running
        1
      else
        3
      end
    end

    def redirect_io(logfile_name = nil)
      redirect_file_to_target($stdin)
      redirect_stdout(logfile_name)
      redirect_stderr
    end

    def redirect_stderr
      redirect_file_to_target($stderr, $stdout)
      $stderr.sync = true
    end

    def redirect_stdout(logfile_name)
      if logfile_name
        begin
          $stdout.reopen logfile_name, "a"
          $stdout.sync = true
        rescue StandardError
          redirect_file_to_target($stdout)
        end
      else
        redirect_file_to_target($stdout)
      end
    end

    def redirect_file_to_target(file, target = "/dev/null")
      begin
        file.reopen(target)
      rescue; end
    end
  end
end
