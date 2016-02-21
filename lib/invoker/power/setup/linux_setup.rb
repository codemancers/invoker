require "invoker/power/setup/distro/base"
require "facter"
require 'erb'
require 'fileutils'

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

      def uninstall_invoker
        system("systemctl disable socat_invoker.service")
        system("systemctl stop socat_invoker.service")
        system("rm #{Invoker::Power::Distro::Base::SOCAT_SYSTEMD}")
        system("rm #{Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT}")
        initialize_distro_installer
        remove_resolver_file
        drop_to_normal_user
        Invoker::Power::Config.delete
      end

      def resolver_file
        distro_installer.resolver_file
      end

      private

      def initialize_distro_installer
        # Create a new facter check for systemctl (in systemd)
        Facter.add(:systemctl) do
          setcode do
            Facter::Util::Resolution.exec("[ -e /usr/bin/systemctl ] && echo 'true' || echo 'false'")
          end
        end
        @distro_installer = Invoker::Power::Distro::Base.distro_installer(tld)
      end

      def install_resolver
        File.open(resolver_file, "w") do |fl|
          fl.write(resolver_file_content)
        end
      end

      def install_port_forwarder
        install_forwarder_script(port_finder.http_port, port_finder.https_port)
        install_systemd_unit()
      end

      def resolver_file_content
        content =<<-EOD
local=/#{tld}/
address=/#{tld}/127.0.0.1
        EOD
        content
      end

      def install_forwarder_script(http_port, https_port)
        script_file = File.join(File.dirname(__FILE__), "files/invoker_forwarder.sh.erb")
        script_template = File.read(script_file)
        renderer = ERB.new(script_template)
        script_output = renderer.result(binding)
        File.open(Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT, "w") do |fl|
          fl.write(script_output)
        end
        system("chmod +x #{Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT}")
      end

      def install_systemd_unit
        unit_file = File.join(File.dirname(__FILE__), "files/socat_invoker.service")
        FileUtils.cp(unit_file, Invoker::Power::Distro::Base::SOCAT_SYSTEMD)
        system("chmod 644 #{Invoker::Power::Distro::Base::SOCAT_SYSTEMD}")
      end

      def get_user_confirmation?
        Invoker::Logger.puts("Invoker is going to install dnsmasq and socat on this machine."\
          " It is also going to install a local resolver for .#{tld} domain and a socat service"\
          " which will forward all local requests on port 80 and 443 to another port")
        Invoker::Logger.puts("If you still want to proceed with installation, press y.")
        Invoker::CLI::Question.agree("Proceed with installation (y/n) : ")
      end
    end
  end
end
