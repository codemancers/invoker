require "slop"
require "ostruct"

module Invoker
  module Parsers
    class OptionParser
      def self.parse(args)
        selected_command = nil
        
        opts = Slop.parse(args, help: true) do
          on :v, "Print the version" do
            $stdout.puts Invoker::VERSION
          end

          command 'start' do
            banner "Usage : invoker start config.ini \n Start Invoker Process Manager"
            run do |cmd_opts, cmd_args|
              selected_command = OpenStruct.new(:command => 'start', :file => cmd_args.first)
            end
          end

          command 'add' do
            banner "Usage : invoker add process_label \n Start the process with given process_label"
            run do |cmd_opts, cmd_args|
              selected_command = OpenStruct.new(:command => 'add', :command_key => cmd_args.first)
            end
          end

          command 'remove' do
            banner "Usage : invoker remove process_label \n Stop the process with given label"
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

        selected_command || create_default_command(args, opts)
      end

      def self.create_default_command(args,opts)
        if File.exists?(args.first) && File.file?(args.first)
          OpenStruct.new(:command => "start", :file => args.first)
        else
          $stdout.puts opts.inspect
          false
        end
      end

    end
  end
end
