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
          if supports_subdomain?(section['command'])
            @port = @port + 1
            make_option_for_subdomain(section, @port)
          else
            make_option(section)
          end
        end
      end

      def make_option_for_subdomain(section, port)
        OpenStruct.new(
          port: @port,
          label: section.key,
          dir: section["directory"],
          cmd: replace_port_in_command(section["command"], @port)
        )
      end

      def make_option(section)
        OpenStruct.new(
          label: section.key,
          dir: section["directory"],
          cmd: section["command"]
        )
      end

      def supports_subdomain?(command)
        command =~ /\$PORT/
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
