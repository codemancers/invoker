require 'iniparse'

module Invoker
  module Parsers
    class Config
      attr_accessor :processes
      def initialize(filename, port)
        @ini_content = File.read(filename)
        @port = port
        @processes = process_ini(@ini_content)
      end

      def process(label)
        processes.detect {|pconfig|
          pconfig.label == label
        }
      end

      private
      def process_ini(ini_content)
        document = IniParse.parse(ini_content)
        document.map do |section|
          check_directory(section["directory"])
          @port = @port + 1
          OpenStruct.new(
            port: @port,
            label: section.key,
            dir: section["directory"],
            cmd: replace_port_in_command(section["command"], @port)
          )
        end
      end

      def check_directory(app_dir)
        if app_dir && !app_dir.empty? && !File.directory?(app_dir)
          raise Invoker::Errors::InvalidConfig.new("Invalid directory #{app_dir}")
        end
      end

      def replace_port_in_command(command, port)
        command.gsub(/\$PORT/i, port.to_s)
      end
    end
  end
end
