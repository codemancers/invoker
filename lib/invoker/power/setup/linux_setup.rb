require "invoker/power/setup/distro/base"
require "facter"
require 'erb'
require 'fileutils'

module Invoker
  module Power
    class LinuxSetup < Setup
      attr_accessor :distro_installer

      def setup_invoker
        initialize_distro_installer
        if distro_installer.get_user_confirmation?
          find_open_ports
          distro_installer.install_required_software
          install_resolver
          install_port_forwarder
          distro_installer.restart_services
          drop_to_normal_user
          create_config_file
        else
          Invoker::Logger.puts("Invoker is not configured to serve from subdomains".colorize(:red))
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

      def build_power_config
        config = super
        config[:tld] = distro_installer.tld
        config
      end

      def resolver_file
        distro_installer.resolver_file
      end

      def forwarder_script
        File.join(File.dirname(__FILE__), "files/invoker_forwarder.sh.erb")
      end

      def socat_unit
        File.join(File.dirname(__FILE__), "files/socat_invoker.service")
      end

      private

      def initialize_distro_installer
        # Create a new facter check for systemctl (in systemd)
        Facter.add(:systemctl) do
          setcode do
            Facter::Util::Resolution.exec("[ -e /usr/bin/systemctl ] && echo 'true' || echo 'false'")
          end
        end
        @distro_installer ||= Invoker::Power::Distro::Base.distro_installer(tld)
      end

      def install_resolver
        return if resolver_file.nil?
        File.open(resolver_file, "w") do |fl|
          fl.write(resolver_file_content)
        end
      end

      def install_port_forwarder
        install_forwarder_script(port_finder.http_port, port_finder.https_port)
        install_systemd_unit
      end

      def resolver_file_content
        content =<<-EOD
local=/#{tld}/
address=/#{tld}/127.0.0.1
        EOD
        content
      end

      def install_forwarder_script(http_port, https_port)
        script_template = File.read(forwarder_script)
        renderer = ERB.new(script_template)
        script_output = renderer.result(binding)
        File.open(Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT, "w") do |fl|
          fl.write(script_output)
        end
        system("chmod +x #{Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT}")
      end

      def install_systemd_unit
        FileUtils.cp(socat_unit, Invoker::Power::Distro::Base::SOCAT_SYSTEMD)
        system("chmod 644 #{Invoker::Power::Distro::Base::SOCAT_SYSTEMD}")
      end
    end
  end
end
