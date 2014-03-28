require "eventmachine"

module Invoker
  module Power
    class Setup
      RESOLVER_FILE = "/etc/resolver/dev"
      RESOLVER_DIR = "/etc/resolver"

      FIREWALL_PLIST_FILE = "/Library/LaunchDaemons/com.codemancers.invoker.firewall.plist"
      def self.install
        installer = new
        if Invoker.darwin?
          if installer.check_if_setup_can_run?
            installer.setup_invoker
          else
            Invoker::Logger.puts("The setup has been already run.".color(:red))
          end
        else
          Invoker::Logger.puts("Domain feature is currently not supported on systems other than OSX".color(:red))
        end
        installer
      end

      def self.uninstall
        installer = new
        installer.uninstall_invoker
      end

      def setup_invoker
        if setup_resolver_file
          find_open_ports
          install_resolver(port_finder.dns_port)
          install_firewall(port_finder.http_port)
          flush_dns_rules()
          # Before writing the config file, drop down to a normal user
          drop_to_normal_user()
          create_config_file()
        else
          Invoker::Logger.puts("Invoker is not configured to serve from subdomains".color(:red))
        end
        self
      end

      def uninstall_invoker
        uninstall_invoker_flag = Invoker::CLI::Question.agree("Are you sure you want to uninstall firewall rules created by setup (y/n) : ")

        if uninstall_invoker_flag
          remove_resolver_file
          unload_firewall_rule(true)
          flush_dns_rules
          Invoker::Power::Config.delete
          Invoker::Logger.puts("Firewall rules were removed")
        end
      end

      def drop_to_normal_user
        EventMachine.set_effective_user(ENV["SUDO_USER"])
      end

      def flush_dns_rules
        system("dscacheutil -flushcache")
      end

      def create_config_file
        Invoker::Power::Config.create(
          dns_port: port_finder.dns_port,
          http_port: port_finder.http_port
        )
      end

      def find_open_ports
        port_finder.find_ports()
      end

      def port_finder
        @port_finder ||= Invoker::Power::PortFinder.new()
      end

      def install_resolver(dns_port)
        open_resolver_for_write { |fl|
          fl.write(resolve_string(dns_port))
        }
      rescue Errno::EACCES
        Invoker::Logger.puts("Running setup requires root access, please rerun it with sudo".color(:red))
        raise
      end

      def remove_resolver_file
        if File.exists?(RESOLVER_FILE)
          File.delete(RESOLVER_FILE)
        end
      rescue Errno::EACCES
        Invoker::Logger.puts("Running uninstall requires root access, please rerun it with sudo".color(:red))
        raise
      end

      def check_if_setup_can_run?
        !File.exists?(Invoker::Power::Config::CONFIG_LOCATION)
      end

      def install_firewall(balancer_port)
        File.open(FIREWALL_PLIST_FILE, "w") { |fl|
          fl.write(plist_string(balancer_port))
        }
        unload_firewall_rule
        load_firewall_rule
      end

      def load_firewall_rule
        system("launchctl load -Fw #{FIREWALL_PLIST_FILE} 2>/dev/null")
      end

      def unload_firewall_rule(remove = false)
        system("launchctl unload -w #{FIREWALL_PLIST_FILE} 2>/dev/null")
        system("rm -rf #{FIREWALL_PLIST_FILE}") if remove
      end

      # Ripped from POW code
      def plist_string(balancer_port)
        plist =<<-EOD
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.codemancers.invoker</string>
<key>ProgramArguments</key>
<array>
<string>sh</string>
<string>-c</string>
<string>#{firewall_command(balancer_port)}</string>
</array>
<key>RunAtLoad</key>
<true/>
<key>UserName</key>
<string>root</string>
</dict>
</plist>
        EOD
        plist
      end

      def resolve_string(dns_port)
        string =<<-EOD
nameserver 127.0.0.1
port #{dns_port}
        EOD
        string
      end

      # Ripped from Pow code
      def firewall_command(balancer_port)
        "ipfw add fwd 127.0.0.1,#{balancer_port} tcp from any to me dst-port 80 in"\
          "&amp;&amp; sysctl -w net.inet.ip.forwarding=1"
      end

      def setup_resolver_file
        return true unless File.exists?(RESOLVER_FILE)
        Invoker::Logger.puts "Invoker has detected an existing Pow installation. We recommend "\
          "that you uninstall pow and rerun this setup.".color(:red)

        Invoker::Logger.puts "If you have already uninstalled Pow, proceed with installation"\
          " by pressing y/n."

        replace_resolver_flag = Invoker::CLI::Question.agree("Replace Pow configuration (y/n) : ")

        if replace_resolver_flag
          Invoker::Logger.puts "Invoker has overwritten one or more files created by Pow. "\
          "If .dev domains still don't resolve locally. Try turning off the wi-fi"\
          " and turning it on. It will force OSX to reload network configuration".color(:green)
        end
        replace_resolver_flag
      end

      private

      def open_resolver_for_write
        FileUtils.mkdir(RESOLVER_DIR) unless Dir.exists?(RESOLVER_DIR)
        fl = File.open(RESOLVER_FILE, "w")
        yield fl
      ensure
        fl && fl.close
      end

    end
  end
end
