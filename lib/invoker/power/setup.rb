require "highline/import"

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
        if setup_resolver_file
          find_open_ports
          install_resolver(port_finder.dns_port)
          ipfw_number = install_firewall(port_finder.http_port)
          flush_dns_rules()
          # Before writing the config file, drop down to a normal user
          drop_to_normal_user()
          create_config_file(ipfw_number)
        else
          Invoker::Logger.puts("Invoker is not configured to serve from subdomains".color(:red))
        end
        self
      end

      def drop_to_normal_user
        EventMachine.set_effective_user(ENV["SUDO_USER"])
      end

      def flush_dns_rules
        system("dscacheutil -flushcache")
      end

      def create_config_file(ipfw_number)
        Invoker::Power::Config.create(
          dns_port: port_finder.dns_port,
          http_port: port_finder.http_port,
          ipfw_rule_number: ipfw_number
        )
      end

      def find_open_ports
        port_finder.find_ports()
      end

      def port_finder
        @port_finder ||= Invoker::Power::PortFinder.new()
      end

      def install_resolver(dns_port)
        File.open(RESOLVER_FILE, "w") { |fl|
          fl.write(resolve_string(dns_port))
        }
      rescue Errno::EACCES
        Invoker::Logger.puts("Running setup requires root access, please rerun it with sudo".color(:red))
        raise
      end

      def check_if_already_setup?
        File.exists?(Invoker::Power::Config::CONFIG_LOCATION)
      end

      def install_firewall(balancer_port)
        output = `#{firewall_command(balancer_port)}`
        output.split.first
      end

      def resolve_string(dns_port)
        string =<<-EOD
nameserver 127.0.0.1
port #{dns_port}
        EOD
        string
      end

      def firewall_command(balancer_port)
        "ipfw add fwd 127.0.0.1,#{balancer_port} tcp from any to me dst-port 80 in"
      end

      def setup_resolver_file
        return true unless File.exists?(RESOLVER_FILE)
        Invoker::Logger.puts "Invoker has detected an existing Pow installation. We recommend "\
          "that you uninstall pow and rerun this setup."

        agree("Invoker has detected a pre-configured Pow setup, do you want to overwrite it : y/n?")
      end
    end
  end
end
