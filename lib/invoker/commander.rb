require "io/console"
require 'pty'
require "json"
require "dotenv"

module Invoker
  class Commander
    MAX_PROCESS_COUNT = 10
    LABEL_COLORS = [:green, :yellow, :blue, :magenta, :cyan]
    attr_accessor :reactor, :workers, :thread_group, :open_pipes
    attr_accessor :event_manager, :runnables

    def initialize
      # mapping between open pipes and worker classes
      @open_pipes = {}

      # mapping between command label and worker classes
      @workers = {}

      @thread_group = ThreadGroup.new()
      @worker_mutex = Mutex.new()

      @event_manager = Invoker::Event::Manager.new()
      @runnables = []

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
      unix_server_thread = Thread.new { Invoker::IPC::Server.new() }
      thread_group.add(unix_server_thread)
      run_power_server()
      Invoker::CONFIG.processes.each { |process_info| add_command(process_info) }
      at_exit { kill_workers }
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
    def process_list
      Invoker::IPC::Message::ListResponse.from_workers(workers)
    end

    # Start executing given command by their label name.
    #
    # @param command_label [String] Command label of process specified in config file.
    def add_command_by_label(command_label)
      if process_running?(command_label)
        Invoker::Logger.puts "\nProcess '#{command_label}' is already running".color(:red)
        return false
      end

      process_info = Invoker::CONFIG.process(command_label)
      if process_info
        add_command(process_info)
      end
    end

    # Reload a process given by command label
    #
    # @params command_label [String] Command label of process specified in config file.
    def reload_command(reload_message)
      command_label = reload_message.process_name
      if remove_command(reload_message.remove_message)
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
    # @param remove_message [Invoker::IPC::Message::Remove]
    # @return [Boolean] if process existed and was removed else false
    def remove_command(remove_message)
      worker = workers[remove_message.process_name]
      command_label = remove_message.process_name
      return false unless worker
      signal_to_use = remove_message.signal || 'INT'

      Invoker::Logger.puts("Removing #{command_label} with signal #{signal_to_use}".color(:red))
      kill_or_remove_process(worker.pid, signal_to_use, command_label)
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

    def on_next_tick(*args, &block)
      @worker_mutex.synchronize do
        @runnables << OpenStruct.new(:args => args, :block => block)
      end
    end

    def run_runnables
      @runnables.each do |runnable|
        instance_exec(*runnable.args, &runnable.block)
      end
      @runnables = []
    end

    def run_power_server
      return unless Invoker.can_run_balancer?(false)

      powerup_id = Invoker::Power::Powerup.fork_and_start()
      wait_on_pid("powerup_manager", powerup_id)
      at_exit {
        begin
          Process.kill("INT", powerup_id)
        rescue Errno::ESRCH; end
      }
    end

    def load_env(directory = nil)
      directory ||= ENV['PWD']
      default_env = File.join(directory, '.env')
      if File.exist?(default_env)
        Dotenv::Environment.new(default_env)
      else
        {}
      end
    end

    private
    def start_event_loop
      loop do
        reactor.watch_on_pipe()
        run_runnables()
        run_scheduled_events()
      end
    end

    def run_scheduled_events
      event_manager.run_scheduled_events do |event|
        event.block.call()
      end
    end

    def kill_or_remove_process(pid, signal_to_use, command_label)
      process_kill(pid, signal_to_use)
      true
    rescue Errno::ESRCH
      Invoker::Logger.puts("Killing process with #{pid} and name #{command_label} failed".color(:red))
      remove_worker(command_label, false)
      false
    end

    def process_kill(pid, signal_to_use)
      if signal_to_use.to_i == 0
        Process.kill(signal_to_use, -Process.getpgid(pid))
      else
        Process.kill(signal_to_use.to_i, -Process.getpgid(pid))
      end
    end

    def select_color
      selected_color = LABEL_COLORS.shift()
      LABEL_COLORS.push(selected_color)
      selected_color
    end

    # Remove worker from all collections
    def remove_worker(command_label, trigger_event = true)
      worker = @workers[command_label]
      if worker
        @open_pipes.delete(worker.pipe_end.fileno)
        @workers.delete(command_label)
      end
      if trigger_event
        event_manager.trigger(command_label, :worker_removed)
      end
    end

    # add worker to global collections
    def add_worker(worker)
      @open_pipes[worker.pipe_end.fileno] = worker
      @workers[worker.command_label] = worker
      @reactor.add_to_monitor(worker.pipe_end)
    end

    def run_command(process_info, write_pipe)
      command_label = process_info.label

      event_manager.schedule_event(command_label, :exit) { remove_worker(command_label) }

      env_options = load_env(process_info.dir)

      spawn_options = {
        :chdir => process_info.dir || ENV['PWD'], :out => write_pipe, :err => write_pipe,
        :pgroup => true, :close_others => true, :in => :close
      }

      if defined?(Bundler)
        Bundler.with_clean_env do
          spawn(env_options, process_info.cmd, spawn_options)
        end
      else
        spawn(env_options, process_info.cmd, spawn_options)
      end
    end

    def wait_on_pid(command_label,pid)
      raise Invoker::Errors::ToomanyOpenConnections if @thread_group.enclosed?

      thread = Thread.new do
        Process.wait(pid)
        message = "Process with command #{command_label} exited with status #{$?.exitstatus}"
        Invoker::Logger.puts("\n#{message}".color(:red))
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
      return unless Invoker.darwin?

      command_path = `which terminal-notifier`
      if command_path && !command_path.empty?
        system("terminal-notifier -message '#{message}' -title Invoker")
      end
    end

    def install_interrupt_handler
      Signal.trap("INT") do
        kill_workers()
        exit(0)
      end
    end

    def kill_workers
      @workers.each {|key,worker|
        begin
          Process.kill("INT", -Process.getpgid(worker.pid))
        rescue Errno::ESRCH
          puts "Error killing #{key}"
        end
      }
      @workers = {}
    end

    def process_running?(command_label)
      !!workers[command_label]
    end
  end
end
