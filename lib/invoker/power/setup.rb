module Invoker
  module Power
    class Setup
      RESOLVER_FILE = "/etc/resolver/dev"
      def self.install
        installer = new
        unless installer.check_if_already_setup?
          installer.setup_invoker
        else
          Invoker::Logger.puts("The setup has been already run.".color(:red))
        end
      end

      def setup_invoker
        install_resolver
        install_firewall
        system("dscacheutil -flushcache")
        self
      end

      def install_resolver
        File.open(RESOLVER_FILE, "w") { |fl|
          fl.write(resolve_string)
        }
      rescue Errno::EACCES
        Invoker::Logger.puts("Running setup requires root access, please rerun it with sudo".color(:red))
        raise
      end

      def check_if_already_setup?
        File.exists?(CONFIG_LOCATION)
      end

      def install_firewall
        system(firewall_command)
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
