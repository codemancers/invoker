require "socket"
require "thor"

module Invoker
  class CLI < Thor
    def self.start(*args)
      cli_args = args.flatten
      # If it is not a valid task, it is probably file argument
      if default_start_command?(cli_args)
        args = [cli_args.unshift("start")]
      end
      super(*args)
    end

    desc "setup", "Run Invoker setup"
    option :tld,
      type: :string,
      banner: 'Configure invoker to use a different top level domain'
    def setup
      Invoker::Power::Setup.install(get_tld(options))
    end

    desc "version", "Print Invoker version"
    def version
      Invoker::Logger.puts Invoker::VERSION
    end
    map %w(-v --version) => :version

    desc "uninstall", "Uninstall Invoker and all installed files"
    def uninstall
      Invoker::Power::Setup.uninstall
    end

    desc "start [CONFIG_FILE]", "Start Invoker Server"
    option :port, type: :numeric, banner: "Port series to be used for starting rack servers"
    option :daemon,
      type: :boolean,
      banner: "Daemonize the server into the background",
      aliases: [:d]
    option :nocolors,
      type: :boolean,
      banner: "Disable color in output",
      aliases: [:nc]
    option :certificate,
      type: :string,
      banner: "Path to certificate"
    option :private_key,
      type: :string,
      banner: "Path to private key"
    def start(file = nil)
      Invoker.setup_config_location
      port = options[:port] || 9000
      Invoker.daemonize = options[:daemon]
      Invoker.nocolors = options[:nocolors]
      Invoker.certificate = options[:certificate]
      Invoker.private_key = options[:private_key]
      Invoker.load_invoker_config(file, port)
      warn_about_notification
      warn_about_old_configuration
      pinger = Invoker::CLI::Pinger.new(unix_socket)
      abort("Invoker is already running".colorize(:red)) if pinger.invoker_running?
      Invoker.commander.start_manager
    end

    desc "add process", "Add a program to Invoker server"
    def add(name)
      unix_socket.send_command('add', process_name: name)
    end

    desc "add_http process_name port [IP]", "Add an external http process to Invoker DNS server"
    def add_http(name, port, ip = nil)
      unix_socket.send_command('add_http', process_name: name, port: port, ip: ip)
    end

    desc "tail process1 process2", "Tail a particular process"
    def tail(*names)
      tailer = Invoker::CLI::Tail.new(names)
      tailer.run
    end

    desc "log process1", "Get log of particular process"
    def log(process_name)
      system("egrep -a '^#{process_name}' #{Invoker.daemon.log_file}")
    end

    desc "reload process", "Reload a process managed by Invoker"
    option :signal,
      banner: "Signal to send for killing the process, default is SIGINT",
      aliases: [:s]
    def reload(name)
      signal = options[:signal] || 'INT'
      unix_socket.send_command('reload', process_name: name, signal: signal)
    end

    desc "list", "List all running processes"
    option :raw,
      type: :boolean,
      banner: "Print process list in raw text format",
      aliases: [:r]
    def list
      unix_socket.send_command('list') do |response_object|
        if options[:raw]
          Invoker::ProcessPrinter.new(response_object).tap { |printer| printer.print_raw_text }
        else
          Invoker::ProcessPrinter.new(response_object).tap { |printer| printer.print_table }
        end
      end
    end

    desc "remove process", "Stop a process managed by Invoker"
    option :signal,
      banner: "Signal to send for killing the process, default is SIGINT",
      aliases: [:s]
    def remove(name)
      signal = options[:signal] || 'INT'
      unix_socket.send_command('remove', process_name: name, signal: signal)
    end

    desc "stop", "Stop Invoker daemon"
    def stop
      Invoker.daemon.stop
    end

    private

    def self.default_start_command?(args)
      command_name = args.first
      command_name &&
        !command_name.match(/^-/) &&
        !valid_tasks.include?(command_name)
    end

    def self.valid_tasks
      tasks.keys + ["help"]
    end

    def get_tld(options)
      if options[:tld] && !options[:tld].empty?
        options[:tld]
      else
        'dev'
      end
    end

    def unix_socket
      Invoker::IPC::UnixClient.new
    end

    def warn_about_notification
      if Invoker.darwin?
        warn_about_terminal_notifier
      else
        warn_about_libnotify
      end
    end

    def warn_about_libnotify
      require "libnotify"
    rescue LoadError
      Invoker::Logger.puts "You can install libnotify gem for Invoker notifications "\
        "via system tray".colorize(:red)
    end

    def warn_about_terminal_notifier
      if Invoker.darwin?
        command_path = `which terminal-notifier`
        if !command_path || command_path.empty?
          Invoker::Logger.puts "You can enable OSX notification for processes "\
            "by installing terminal-notifier gem".colorize(:red)
        end
      end
    end

    def warn_about_old_configuration
      Invoker::Power::PfMigrate.new.tap do |pf_migrator|
        pf_migrator.migrate
      end
    end
  end
end

require "invoker/cli/question"
require "invoker/cli/tail_watcher"
require "invoker/cli/tail"
require "invoker/cli/pinger"
