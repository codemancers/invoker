module Invoker
  module Power
    # Installs firewalls required for power to work
    class Setup
      def self.install
        installer = new
        installer.install_resolver
        system(installer.firewall_command)
        system("dscacheutil -flushcache")
        installer
      end

      def install_resolver
        File.open("/etc/resolver/invoker", "w") { |fl|
          fl.write(resolve_string)
        }
      rescue Errno::EACCES
        Invoker::Logger.puts("Running setup requires root access, please rerun it with sudo")
        raise
      end

      def resolve_string
        string =<<-EOD
nameserver 127.0.0.1
port 23400
        EOD
        string
      end

      def firewall_command
        "ipfw add fwd 127.0.0.1,23401 tcp from any to me dst-port 80 in"
      end
    end
  end
end
