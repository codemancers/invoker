require "slop"
require "ostruct"
require "socket"

module Invoker
  class Runner
    def self.run(args)
    end

    def self.run_command(selected_command)
      return unless selected_command
      case selected_command.command
      when 'start'
        start_server(selected_command)
      when 'add'
        add_command(selected_command)
      when 'remove'
        remove_command(selected_command)
      else
        $stdout.puts "Invalid command"
      end
    end

    def self.start_server(selected_command)
      config = Invoker::Config.new(selected_command.file)
      Invoker.const_set(:CONFIG, config)
      warn_about_terminal_notifier()
      commander = Invoker::Commander.new()
      Invoker.const_set(:COMMANDER, commander)
      commander.start_manager()
    end

    def self.add_command(selected_command)
      socket = UNIXSocket.open(Invoker::CommandListener::Server::SOCKET_PATH)
      socket.puts("add #{selected_command.command_key}")
      socket.flush()
      socket.close()
    end

    def self.remove_command(selected_command)
      socket = UNIXSocket.open(Invoker::CommandListener::Server::SOCKET_PATH)
      socket.puts("remove #{selected_command.command_key} #{selected_command.signal}")
      socket.flush()
      socket.close()
    end

    def self.refresh_command(selected_command)
      socket = UNIXSocket.open(Invoker::CommandListener::Server::SOCKET_PATH)
      socket.puts("reload #{selected_command.command_key}")
      socket.flush()
      socket.close()
    end

    def self.warn_about_terminal_notifier
      if RUBY_PLATFORM.downcase.include?("darwin")
        command_path = `which terminal-notifier`
        if !command_path || command_path.empty?
          $stdout.puts("You can enable OSX notification for processes by installing terminal-notification gem".red)
        end
      end
    end

  end
end
