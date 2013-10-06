require 'iniparse'

module Invoker
  module Parsers
    class Config
      PORT_REGEX = /\$PORT/
      attr_accessor :processes, :power_config

      def initialize(filename, port)
        @ini_content = File.read(filename)
        @port = port
        @processes = process_ini(@ini_content)
        if Invoker.can_run_balancer?
          @power_config = Invoker::Power::Config.load_config()
        end
      end

      def http_port
        power_config && power_config.http_port
      end

      def dns_port
        power_config && power_config.dns_port
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
          if supports_subdomain?(section)
            port = pick_port(section)
            make_option_for_subdomain(section, port)
          else
            make_option(section)
          end
        end
      end

      def pick_port(section)
        if section['command'] =~ PORT_REGEX
          @port += 1
        elsif section['port']
          section['port']
        else
          nil
        end
      end

      def make_option_for_subdomain(section, port)
        OpenStruct.new(
          port: port,
          label: section.key,
          dir: section["directory"],
          cmd: replace_port_in_command(section["command"], port)
        )
      end

      def make_option(section)
        OpenStruct.new(
          label: section.key,
          dir: section["directory"],
          cmd: section["command"]
        )
      end

      def supports_subdomain?(section)
        (section['command'] =~ PORT_REGEX) || section['port']
      end

      def check_directory(app_dir)
        if app_dir && !app_dir.empty? && !File.directory?(app_dir)
          raise Invoker::Errors::InvalidConfig.new("Invalid directory #{app_dir}")
        end
      end

      def replace_port_in_command(command, port)
        if command =~ PORT_REGEX
          command.gsub(PORT_REGEX, port.to_s)
        else
          command
        end
      end

    end
  end
end
