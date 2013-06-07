require "slop"
require "ostruct"
require "socket"

module Necro
  class Runner
    def self.run(args)

      selected_command = nil
      
      Slop.parse(args, help: true) do
        on :v, "Print the version" do
          $stdout.puts Necro::VERSION
        end

        command 'start' do
          banner "Usage : necro start config.ini \n Start Necro Process Manager"
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'start', :file => cmd_args.first)
          end
        end

        command 'add' do
          banner "Usage : necro add process_label \n Start the process with given process_label"
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'add', :command_key => cmd_args.first)
          end
        end

        command 'remove' do
          banner "Usage : necro remove process_label \n Stop the process with given label"
          on :s, :signal=, "Signal to send for killing the process, default is SIGINT", as: String

          run do |cmd_opts, cmd_args|
            signal_to_use = cmd_opts.to_hash[:signal] || 'INT'
            selected_command = OpenStruct.new(
              :command => 'remove', 
              :command_key => cmd_args.first,
              :signal => signal_to_use
            )
          end
        end
      end
      run_command(selected_command)
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
      config = Necro::Config.new(selected_command.file)
      Necro.const_set(:CONFIG, config)
      warn_about_terminal_notifier()
      commander = Necro::Commander.new()
      Necro.const_set(:COMMANDER, commander)
      commander.start_manager()
    end

    def self.add_command(selected_command)
      socket = UNIXSocket.open(Necro::CommandListener::Server::SOCKET_PATH)
      socket.puts("add #{selected_command.command_key}")
      socket.flush()
      socket.close()
    end

    def self.remove_command(selected_command)
      socket = UNIXSocket.open(Necro::CommandListener::Server::SOCKET_PATH)
      socket.puts("remove #{selected_command.command_key} #{selected_command.signal}")
      socket.flush()
      socket.close()
    end

    def self.refresh_command(selected_command)
      socket = UNIXSocket.open(Necro::CommandListener::Server::SOCKET_PATH)
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
