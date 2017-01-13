module Invoker
  module Power
    module Distro
      class Base
        SOCAT_SHELLSCRIPT = "/usr/bin/invoker_forwarder.sh"
        SOCAT_SYSTEMD = "/etc/systemd/system/socat_invoker.service"
        RESOLVER_DIR = "/etc/dnsmasq.d"
        attr_accessor :tld

        def resolver_file
          File.join(RESOLVER_DIR, "#{tld}-tld")
        end

        def self.distro_installer(tld)
          case Facter[:operatingsystem].value
          when "Ubuntu"
            require "invoker/power/setup/distro/ubuntu"
            Ubuntu.new(tld)
          when "Fedora"
            require "invoker/power/setup/distro/redhat"
            Redhat.new(tld)
          when "Archlinux", "Manjarolinux"
            require "invoker/power/setup/distro/arch"
            Arch.new(tld)
          when "Debian"
            require "invoker/power/setup/distro/debian"
            Debian.new(tld)
          when "LinuxMint"
            require "invoker/power/setup/distro/mint"
            Mint.new(tld)
          when "OpenSuSE"
            require "invoker/power/setup/distro/opensuse"
            Opensuse.new(tld)
          else
            raise "Your selected distro is not supported by Invoker"
          end
        end

        def initialize(tld)
          self.tld = tld
        end

        # Install required software
        def install_required_software
          raise "Unimplemented"
        end

        def restart_services
          system("systemctl enable socat_invoker.service")
          system("systemctl enable dnsmasq")
          system("systemctl start socat_invoker.service")
          system("systemctl restart dnsmasq")
        end
      end
    end
  end
end
