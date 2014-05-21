require "eventmachine"

module Invoker
  module Power
    class Setup
      attr_accessor :port_finder
      def self.install
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
        !File.exists?(Invoker::Power::Config::CONFIG_LOCATION)
      end
    end
  end
end
