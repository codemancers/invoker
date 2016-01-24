require "eventmachine"
require "invoker/power/tld"

module Invoker
  module Power
    class Setup
      attr_accessor :port_finder

      def self.install(options = {})
        validate_tld(options[:tld])

        Invoker::Power.tld_value = options[:tld]
        selected_installer_klass = installer_klass
        selected_installer_klass.new.install
      end

      def self.uninstall
        selected_installer_klass = installer_klass
        selected_installer_klass.new.uninstall_invoker
      end

      def self.installer_klass
        if Invoker.darwin?
          Invoker::Power::OsxSetup
        else
          Invoker::Power::LinuxSetup
        end
      end

      def self.validate_tld(tld)
        Invoker::Power::Tld.new(tld).validate
      end

      def install
        if check_if_setup_can_run?
          setup_invoker
        else
          Invoker::Logger.puts("The setup has been already run.".color(:red))
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

      # Builds and return power config hash. Override in subclasses if necessary.
      def build_power_config
        config = {
          http_port: port_finder.http_port,
          https_port: port_finder.https_port
        }
        tld = Invoker::Power.tld
        config[:tld] = tld.value if tld.custom?
        config
      end
    end
  end
end
