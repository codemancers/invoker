module Invoker
  module Power
    class LinuxSetup < Setup
      RESOLVER_FILE = "/etc/dnsmasq.d/dev-tld"
      RINETD_FILE = "/etc/rinetd.conf"

      def setup_invoker
        if get_user_confirmation?
          find_open_ports
          install_required_software
          install_resolver
          install_port_forwarder
          restart_services
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

      def restart_services
        system("/etc/init.d/rinetd restart")
        system("/etc/init.d/dnsmasq restart")
      end

      def install_required_software
        system("apt-get --assume-yes install dnsmasq rinetd")
      end

      def install_resolver
        File.open(RESOLVER_FILE, "w") do |fl|
          fl.write(tld_setup)
        end
      end

      def install_port_forwarder
        File.open(RINETD_FILE, "a") do |fl|
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
