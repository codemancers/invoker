module Invoker
  module Power
    class OsxSetup < Setup
      FIREWALL_PLIST_FILE = "/Library/LaunchDaemons/com.codemancers.invoker.firewall.plist"
      RESOLVER_DIR = "/etc/resolver"

      def resolver_file
        File.join(RESOLVER_DIR, tld)
      end

      def setup_invoker
        if setup_resolver_file
          find_open_ports
          install_resolver(port_finder.dns_port)
          install_firewall(port_finder.http_port, port_finder.https_port)
          # Before writing the config file, drop down to a normal user
          drop_to_normal_user
          create_config_file
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
          Invoker::Power::Config.delete
          Invoker::Logger.puts("Firewall rules were removed")
        end
      end

      def build_power_config
        config = super
        config[:dns_port] = port_finder.dns_port
        config
      end

      def install_resolver(dns_port)
        open_resolver_for_write { |fl| fl.write(resolve_string(dns_port)) }
      rescue Errno::EACCES
        Invoker::Logger.puts("Running setup requires root access, please rerun it with sudo".color(:red))
        raise
      end

      def install_firewall(http_port, https_port)
        File.open(FIREWALL_PLIST_FILE, "w") { |fl|
          fl.write(plist_string(http_port, https_port))
        }
        unload_firewall_rule
        load_firewall_rule
      end

      def load_firewall_rule
        system("launchctl load -Fw #{FIREWALL_PLIST_FILE} 2>/dev/null")
      end

      def unload_firewall_rule(remove = false)
        system("pfctl -a com.apple/250.InvokerFirewall -F nat 2>/dev/null")
        system("launchctl unload -w #{FIREWALL_PLIST_FILE} 2>/dev/null")
        system("rm -rf #{FIREWALL_PLIST_FILE}") if remove
      end

      # Ripped from POW code
      def plist_string(http_port, https_port)
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
<string>#{firewall_command(http_port, https_port)}</string>
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
      def firewall_command(http_port, https_port)
        rules = [
          "rdr pass on lo0 inet proto tcp from any to any port 80 -> 127.0.0.1 port #{http_port}",
          "rdr pass on lo0 inet proto tcp from any to any port 443 -> 127.0.0.1 port #{https_port}"
        ].join("\n")
        "echo \"#{rules}\" | pfctl -a 'com.apple/250.InvokerFirewall' -f - -E"
      end

      def setup_resolver_file
        return true unless File.exit?(resolver_file)

        Invoker::Logger.puts "Invoker has detected an existing Pow installation. We recommend "\
          "that you uninstall pow and rerun this setup.".color(:red)
        Invoker::Logger.puts "If you have already uninstalled Pow, proceed with installation"\
          " by pressing y/n."
        replace_resolver_flag = Invoker::CLI::Question.agree("Replace Pow configuration (y/n) : ")

        if replace_resolver_flag
          Invoker::Logger.puts "Invoker has overwritten one or more files created by Pow. "\
          "If .#{tld} domains still don't resolve locally, try turning off the wi-fi"\
          " and turning it on. It'll force OS X to reload network configuration".color(:green)
        end
        replace_resolver_flag
      end

      private

      def open_resolver_for_write
        FileUtils.mkdir(RESOLVER_DIR) unless Dir.exist?(RESOLVER_DIR)
        fl = File.open(resolver_file, "w")
        yield fl
      ensure
        fl && fl.close
      end
    end
  end
end
