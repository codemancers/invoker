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
    def setup
      Invoker::Power::Setup.install
    end

    desc "version", "Print invoker version"
    def version
      Invoker::Logger.puts Invoker::VERSION
    end
    map %w(-v --version) => :version

    desc "uninstall", "Uninstall Invoker and all installed files"
    def uninstall
      Invoker::Power::Setup.uninstall
    end

    desc "start CONFIG_FILE", "Start Invoker Server"
    option :port, type: :numeric, banner: "Port series to be used for starting rack servers"
    def start(file)
      port = options[:port] || 9000
      Invoker.load_invoker_config(file, port)
      warn_about_terminal_notifier
      Invoker.commander.start_manager
    end

    desc "add process", "Add a program to Invoker server"
    def add(name)
      unix_socket.send_command('add', process_name: name)
    end

    desc "add_http process_name port", "Add an external http process to Invoker DNS server"
    def add_http(name, port)
      unix_socket.send_command('add_http', process_name: name, port: port)
    end

    desc "tail process_name", "Tail a particular process"
    def tail(name)
      tailer = Invoker::CLI::Tail.new(name)
      tailer.run
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
    def list
      unix_socket.send_command('list') do |response_object|
        Invoker::ProcessPrinter.new(response_object).tap { |printer| printer.print_table }
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

    private

    def self.default_start_command?(args)
      return false if args.length != 1
      command_name = args.first
      command_name &&
        !command_name.match(/^-/) &&
        !tasks.keys.include?(command_name)
    end

    def unix_socket
      Invoker::IPC::UnixClient.new
    end

    def warn_about_terminal_notifier
      if RUBY_PLATFORM.downcase.include?("darwin")
        command_path = `which terminal-notifier`
        if !command_path || command_path.empty?
          Invoker::Logger.puts "You can enable OSX notification for processes "\
            "by installing terminal-notifier gem".color(:red)
        end
      end
    end
  end
end

require "invoker/cli/question"
require "invoker/cli/tail_watcher"
require "invoker/cli/tail"