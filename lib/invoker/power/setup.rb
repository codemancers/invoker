require "eventmachine"
require "invoker/power/tld_validator"

module Invoker
  module Power
    class Setup
      attr_accessor :port_finder

      def self.install(options = {})
        selected_installer_klass = installer_klass

        if options[:tld]
          validate_tld(options[:tld])  
          selected_installer_klass.tld = tld
        end
        installer = selected_installer_klass.new
        installer.install
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
        Invoker::Power::TldValidator.validate(tld)
      end

      def self.tld=(tld)
        @@tld = tld
      end

      def self.tld
        class_variable_defined?(:@@tld) ? @@tld : Invoker.default_tld
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

      # Builds and returns power config hash. Override this method in subclasses if necessary.
      def build_power_config
        config = {
          http_port: port_finder.http_port,
          https_port: port_finder.https_port
        }
        tld = self.class.tld
        config[:tld] = tld if Invoker.custom_tld?(tld)
        config
      end

      def remove_resolver_file
        set_tld

        begin
          safe_remove_file(resolver_file)
        rescue Errno::EACCES
          Invoker::Logger.puts("Running uninstall requires root access, please rerun it with sudo".color(:red))
          raise
        end
      end

      # Load tld from power config file
      def set_tld
        power_config = Invoker::Power::Config.load_config
        Invoker::Power::Setup.tld = power_config.tld
      end

      def safe_remove_file(file)
        File.delete(file) if File.exists?(file)
      end
    end
  end
end
