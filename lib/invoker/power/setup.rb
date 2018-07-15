require "eventmachine"

module Invoker
  module Power
    class Setup
      attr_accessor :port_finder, :tld

      def self.install(tld)
        selected_installer_klass = installer_klass
        selected_installer_klass.new(tld).install
      end

      def self.uninstall
        if Invoker::Power::Config.has_config?
          power_config = Invoker::Power::Config.load_config
          selected_installer_klass = installer_klass
          selected_installer_klass.new(power_config.tld).uninstall_invoker
        end
      end

      def self.installer_klass
        if Invoker.darwin?
          Invoker::Power::OsxSetup
        else
          Invoker::Power::LinuxSetup
        end
      end

      def initialize(tld)
        if tld !~ /^[a-z]+$/
          Invoker::Logger.puts("Please specify valid tld".colorize(:red))
          exit(1)
        end
        self.tld = tld
      end

      def install
        if check_if_setup_can_run?
          setup_invoker
        else
          Invoker::Logger.puts("The setup has been already run.".colorize(:red))
        end
        self
      end

      def drop_to_normal_user
        EventMachine.set_effective_user(ENV["SUDO_USER"])
      end

      def find_open_ports
        port_finder.find_ports()
      end

      def port_finder
        @port_finder ||= Invoker::Power::PortFinder.new()
      end

      def check_if_setup_can_run?
        !File.exists?(Invoker::Power::Config.config_file)
      end

      def create_config_file
        Invoker.setup_config_location
        config = build_power_config
        Invoker::Power::Config.create(config)
      end

      # Builds and returns power config hash. Override this method in subclasses if necessary.
      def build_power_config
        config = {
          http_port: port_finder.http_port,
          https_port: port_finder.https_port,
          tld: tld
        }
        config
      end

      def remove_resolver_file
        begin
          safe_remove_file(resolver_file)
        rescue Errno::EACCES
          Invoker::Logger.puts("Running uninstall requires root access, please rerun it with sudo".colorize(:red))
          raise
        end
      end

      def safe_remove_file(file)
        File.delete(file) if File.exists?(file)
      end
    end
  end
end
