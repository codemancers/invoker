require "invoker/power/setup/distro/base"
require "facter"

module Invoker
  module Power
    class LinuxSetup < Setup
      attr_accessor :distro_installer

      def setup_invoker
        if get_user_confirmation?
          initialize_distro_installer
          find_open_ports
          distro_installer.install_required_software
          install_resolver
          install_port_forwarder
          distro_installer.restart_services
          drop_to_normal_user
          create_config_file
        else
          Invoker::Logger.puts("Invoker is not configured to serve from subdomains".color(:red))
        end
        self
      end

      def create_config_file
        Invoker.setup_config_location
        Invoker::Power::Config.create(
          http_port: port_finder.http_port,
          https_port: port_finder.https_port
        )
      end

      def uninstall_invoker
        Invoker::Logger.puts("Uninstall is not yet supported on Linux."\
          " You can remove invoker changes by uninstalling dnsmasq and rinetd")
      end

      private

      def initialize_distro_installer
        # Create a new facter check for systemctl (in systemd)
        Facter.add(:systemctl) do
          setcode do
            Facter::Util::Resolution.exec("[ -e /usr/bin/systemctl ] && echo 'true' || echo 'false'")
          end
        end
        @distro_installer =  Invoker::Power::Distro::Base.distro_installer
      end

      def install_resolver
        File.open(distro_installer.resolver_file, "w") do |fl|
          fl.write(tld_setup)
        end
      end

      def install_port_forwarder
        File.open(distro_installer.rinetd_file, "a") do |fl|
          fl << "\n"
          fl << rinetd_setup(port_finder.http_port, port_finder.https_port)
        end
      end

      def tld_setup
        tld_string =<<-EOD
local=/dev/
address=/dev/127.0.0.1
        EOD
        tld_string
      end

      def rinetd_setup(http_port, https_port)
        rinetd_string =<<-EOD
0.0.0.0 80 0.0.0.0 #{http_port}
0.0.0.0 443 0.0.0.0 #{https_port}
        EOD
        rinetd_string
      end

      def get_user_confirmation?
        Invoker::Logger.puts("Invoker is going to install dnsmasq and rinetd on this machine."\
          " It is also going to install a local resolver for .dev domain and a rinetd rule"\
          " which will forward all local requests on port 80 and 443 to another port")
        Invoker::Logger.puts("If you still want to proceed with installation, press y.")
        Invoker::CLI::Question.agree("Proceed with installation (y/n) : ")
      end
    end
  end
end
