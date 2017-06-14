require "io/console"
require 'pty'
require "json"
require "dotenv"
require "forwardable"

module Invoker
  class Commander
    attr_accessor :reactor, :process_manager
    attr_accessor :event_manager, :runnables, :thread_group
    extend Forwardable

    def_delegators :@process_manager, :start_process_by_name, :stop_process
    def_delegators :@process_manager, :restart_process, :get_worker_from_fd, :process_list

    def_delegators :@event_manager, :schedule_event, :trigger
    def_delegator :@reactor, :watch_for_read

    def initialize
      @thread_group = ThreadGroup.new
      @runnable_mutex = Mutex.new

      @event_manager = Invoker::Event::Manager.new
      @runnables = []

      @reactor = Invoker::Reactor.new
      @process_manager = Invoker::ProcessManager.new
      Thread.abort_on_exception = true
    end

    # Start the invoker process supervisor. This method starts a unix server
    # in separate thread that listens for incoming commands.
    def start_manager
      verify_process_configuration
      daemonize_app if Invoker.daemonize?
      install_interrupt_handler
      unix_server_thread = Thread.new { Invoker::IPC::Server.new }
      @thread_group.add(unix_server_thread)
      process_manager.run_power_server
      Invoker.config.autorunnable_processes.each do |process_info|
        process_manager.start_process(process_info)
        Logger.puts("Starting process - #{process_info.label} waiting for #{process_info.sleep_duration} seconds...")
        sleep(process_info.sleep_duration)
      end
      at_exit { process_manager.kill_workers }
      start_event_loop
    end

    def on_next_tick(*args, &block)
      @runnable_mutex.synchronize do
        @runnables << OpenStruct.new(:args => args, :block => block)
      end
    end

    def run_runnables
      @runnables.each do |runnable|
        instance_exec(*runnable.args, &runnable.block)
      end
      @runnables = []
    end

    private

    def verify_process_configuration
      if !Invoker.config.processes || Invoker.config.processes.empty?
        raise Invoker::Errors::InvalidConfig.new("No processes configured in config file")
      end
    end

    def start_event_loop
      loop do
        reactor.monitor_for_fd_events
        run_runnables
        run_scheduled_events
      end
    end

    def run_scheduled_events
      event_manager.run_scheduled_events do |event|
        event.block.call
      end
    end

    def install_interrupt_handler
      Signal.trap("INT") {
        Invoker::Logger.puts("Stopping invoker")
        process_manager.kill_workers
        exit(0)
      }
      Signal.trap("TERM") {
        Invoker::Logger.puts("Stopping invoker")
        process_manager.kill_workers
        exit(0)
      }
    end

    def daemonize_app
      Invoker.daemon.start
    end
  end
end
