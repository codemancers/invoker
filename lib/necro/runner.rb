require "slop"
require "ostruct"
require "socket"

module Necro
  class Runner
    def self.run(args)

      selected_command = nil
      
      Slop.parse(args, help: true) do
        on :v, "Print the version" do
          puts Necro::VERSION
        end

        command 'start' do
          on :h, :help, "config_file : Start the Necro Server"
          
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'start', :file => cmd_args.first)
          end
        end

        command 'add' do
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'add', :command_key => cmd_args.first)
          end
        end

        command 'remove' do
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'remove', :command_key => cmd_args.first)
          end
        end

        command 'refresh' do
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'refresh', :command_key => cmd_args.first)
          end
        end

        command 'stop' do
          run do |cmd_opts, cmd_args|
            selected_command = OpenStruct.new(:command => 'stop', :command_key => cmd_args[1])
          end
        end
      end
      run_command(selected_command)
    end

    def self.run_command(selected_command)
      case selected_command.command
      when 'start'
        start_server(selected_command)
      when 'stop'
        stop_server()
      when 'add'
        add_command(selected_command)
      when 'remove'
        remove_command(selected_command)
      when 'refresh'
        refresh_command(selected_command)
      else
        puts "Invalid command"
      end
    end

    def self.start_server(selected_command)
      config = Necro::Config.new(selected_command.file)
      Necro.const_set(:CONFIG, config)
      commander = Necro::Commander.new()
      Necro.const_set(:COMMANDER, commander)
      commander.start_reactor()
    end

    def self.add_command(selected_command)
      socket = UNIXSocket.open(Necro::Master::Server::SOCKET_PATH)
      socket.puts("add #{selected_command.command_key}")
      socket.flush()
    end

    def self.remove_command(selected_command)
      socket = UNIXSocket.open(Necro::Master::Server::SOCKET_PATH)
      socket.puts("remove #{selected_command.command_key}")
      socket.flush()
    end

    def self.refresh_command(selected_command)
      socket = UNIXSocket.open(Necro::Master::Server::SOCKET_PATH)
      socket.puts("reload #{selected_command.command_key}")
      socket.flush()
    end
  end
end
