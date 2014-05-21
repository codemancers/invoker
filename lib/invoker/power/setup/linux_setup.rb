module Invoker
  module Power
    class LinuxSetup
      RESOLVER_FILE = "/etc/dnsmasq.d/dev-tld"
      RINETD_FILE = "/etc/rinetd.conf"

      def setup_invoker
        if get_user_confirmation?
          find_open_ports
          install_required_software
          install_resolver
          install_port_forwarder()
          restart_services
        end
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
          fl << rinetd_setup
        end
      end

      def tld_setup
        tld_string =<<-EOD
local=/dev/
address=/dev/127.0.0.1
        EOD
        tld_string
      end

      def rinetd_setup
        rinetd_string =<<-EOD
0.0.0.0 80 0.0.0.0 23400
0.0.0.0 443 0.0.0.0 23401
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
