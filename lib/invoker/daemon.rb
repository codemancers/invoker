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
      elsif(dead?)
        File.delete(pid_file) if File.exists?(pid_file)
      end
      Invoker::Logger.puts "Running Invoker daemon"
      daemonize
    end

    def stop
      kill_process
    end

    def pid_file
      "/tmp/#{process_name}.pid"
    end

    def pid
      File.read(pid_file).strip.to_i
    end

    def daemonize
      if fork                     # Parent exits, child continues.
        sleep(5)
        exit(0)
      else
        Process.setsid
        File.open(pid_file, "w") do |file|
          file.write(Process.pid.to_s)
        end
        redirect_io
        $0 = process_name
      end
    end

    def kill_process
      pgid =  Process.getpgid(pid)
      Process.kill('-TERM', pgid)
      File.delete(pid_file) if File.exists?(pid_file)
      Invoker::Logger.puts "Stopped Invoker daemon"
    end

    def process_running?
      begin
        Process.kill(0, self.pid)
        true
      rescue Errno::ESRCH
        false
      end
    end

    def status
      @status ||= begin
                    if pidfile_exists? and process_running?
                      0
                    elsif pidfile_exists? # but not process_running
                      1
                    else
                      3
                    end
                  end
    end

    def pidfile_exists?
      File.exists?(pid_file)
    end

    def running?
      status == 0
    end

    # pidfile exists but process isn't running
    def dead?
      status == 1
    end

    private

    def redirect_io(logfile_name = nil)
      begin
        ; STDIN.reopen "/dev/null";
      rescue ::Exception;
      end

      if logfile_name
        begin
          STDOUT.reopen logfile_name, "a"
          STDOUT.sync = true
        rescue ::Exception
          begin
            ; STDOUT.reopen "/dev/null";
          rescue ::Exception;
          end
        end
      else
        begin
          ; STDOUT.reopen "/dev/null";
        rescue ::Exception;
        end
      end

      begin
        ; STDERR.reopen STDOUT;
      rescue ::Exception;
      end
      STDERR.sync = true
    end
  end
end
