require "io/console"
require 'pty'

module Invoker
  class Commander
    MAX_PROCESS_COUNT = 10
    LABEL_COLORS = ['green', 'yellow', 'blue', 'magenta', 'cyan']
    attr_accessor :reactor, :workers, :thread_group, :open_pipes
    attr_accessor :event_manager
    
    def initialize
      # mapping between open pipes and worker classes
      @open_pipes = {}

      # mapping between command label and worker classes
      @workers = {}
      
      @thread_group = ThreadGroup.new()
      @worker_mutex = Mutex.new()

      @event_manager = Invoker::Event::Manager.new()

      @reactor = Invoker::Reactor.new
      Thread.abort_on_exception = true
    end

    # Start the invoker process supervisor. This method starts a unix server
    # in separate thread that listens for incoming commands.
    def start_manager
      if !Invoker::CONFIG.processes || Invoker::CONFIG.processes.empty?
        raise Invoker::Errors::InvalidConfig.new("No processes configured in config file")
      end
      install_interrupt_handler()
      unix_server_thread = Thread.new { Invoker::CommandListener::Server.new() }
      thread_group.add(unix_server_thread)
      Invoker::CONFIG.processes.each { |process_info| add_command(process_info) }
      start_event_loop()
    end

    # Start given command and start a background thread to wait on the process
    #
    # @param process_info [OpenStruct(command, directory)]
    def add_command(process_info)
      m, s = PTY.open
      s.raw! # disable newline conversion.

      pid = run_command(process_info, s)

      s.close()

      worker = Invoker::CommandWorker.new(process_info.label, m, pid, select_color())

      add_worker(worker)
      wait_on_pid(process_info.label,pid)
    end

    # List currently running commands
    def list_commands
      tp workers
    end

    # Start executing given command by their label name.
    #
    # @param command_label [String] Command label of process specified in config file.
    def add_command_by_label(command_label)
      process_info = Invoker::CONFIG.processes.detect {|pconfig|
        pconfig.label == command_label
      }
      if process_info
        add_command(process_info)
      end
    end

    # Reload a process given by command label
    #
    # @params command_label [String] Command label of process specified in config file.
    def reload_command(command_label, rest_args)
      if remove_command(command_label, rest_args)
        event_manager.schedule_event(command_label, :worker_removed) {
          add_command_by_label(command_label) 
        }
      else
        add_command_by_label(command_label) 
      end
    end

    # Remove a process from list of processes managed by invoker supervisor.It also
    # kills the process before removing it from the list.
    #
    # @param command_label [String] Command label of process specified in config file
    # @param rest_args [Array] Additional option arguments, such as signal that can be used.
    # @return [Boolean] if process existed and was removed else false
    def remove_command(command_label, rest_args)
      worker = workers[command_label]
      signal_to_use = rest_args ? Array(rest_args).first : 'INT'

      if worker
        Invoker::Logger.puts("Removing #{command_label} with signal #{signal_to_use}".red)
        process_kill(worker.pid, signal_to_use)
        return true
      end
      false
    end

    # Given a file descriptor returns the worker object
    #
    # @param fd [IO] an IO object with valid file descriptor
    # @return [Invoker::CommandWorker] The worker object which is associated with this fd
    def get_worker_from_fd(fd)
      open_pipes[fd.fileno]
    end

    # Given a command label returns the associated worker object
    #
    # @param label [String] Command label of the command
    # @return [Invoker::CommandWorker] The worker object which is associated with this command
    def get_worker_from_label(label)
      workers[label]
    end
    
    private
    def start_event_loop
      loop do
        reactor.watch_on_pipe()
        run_scheduled_events()
      end
    end
    
    def run_scheduled_events
      event_manager.run_scheduled_events do |event|
        event.block.call()
      end
    end
    
    def process_kill(pid, signal_to_use)
      if signal_to_use.to_i == 0
        Process.kill(signal_to_use, pid)
      else
        Process.kill(signal_to_use.to_i, pid)
      end
    end

    def select_color
      selected_color = LABEL_COLORS.shift()
      LABEL_COLORS.push(selected_color)
      selected_color
    end
    
    # Remove worker from all collections
    def remove_worker(command_label)
      @worker_mutex.synchronize do
        worker = @workers[command_label]
        if worker
          @open_pipes.delete(worker.pipe_end.fileno)
          @reactor.remove_from_monitoring(worker.pipe_end)
          @workers.delete(command_label)
        end
      end
      event_manager.trigger(command_label, :worker_removed)
    end

    # add worker to global collections
    def add_worker(worker)
      @worker_mutex.synchronize do
        @open_pipes[worker.pipe_end.fileno] = worker
        @workers[worker.command_label] = worker
        @reactor.add_to_monitor(worker.pipe_end)
      end
    end

    def run_command(process_info, write_pipe)
      if defined?(Bundler)
        Bundler.with_clean_env do
          spawn(process_info.cmd, 
            :chdir => process_info.dir || "/", :out => write_pipe, :err => write_pipe
          )
        end
      else
        spawn(process_info.cmd, 
          :chdir => process_info.dir || "/", :out => write_pipe, :err => write_pipe
        )
      end
    end

    def wait_on_pid(command_label,pid)
      raise Invoker::Errors::ToomanyOpenConnections if @thread_group.enclosed?
      event_manager.schedule_event(command_label, :exit) { remove_worker(command_label) }

      thread = Thread.new do
        Process.wait(pid)
        message = "Process with command #{command_label} exited with status #{$?.exitstatus}"
        Invoker::Logger.puts("\n#{message}".red)
        notify_user(message)
        event_manager.trigger(command_label, :exit)
      end
      @thread_group.add(thread)
    end

    def notify_user(message)
      if defined?(Bundler)
        Bundler.with_clean_env do
          check_and_notify_with_terminal_notifier(message)
        end
      else
        check_and_notify_with_terminal_notifier(message)
      end
    end

    def check_and_notify_with_terminal_notifier(message)
      return unless RUBY_PLATFORM.downcase.include?("darwin")

      command_path = `which terminal-notifier`
      if command_path && !command_path.empty?
        system("terminal-notifier -message '#{message}' -title Invoker")
      end
    end

    def install_interrupt_handler
      Signal.trap("INT") do
        @workers.each {|key,worker|
          begin
            Process.kill("INT", worker.pid) 
          rescue Errno::ESRCH
          end
        }
        exit(0)
      end
    end

  end
end
