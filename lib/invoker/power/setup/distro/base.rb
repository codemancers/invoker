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

        def install_packages
          "dnsmasq and socat"
        end

        def install_other
          " a local resolver for .#{tld} domain and"
        end

        def get_user_confirmation?
          Invoker::Logger.puts("Invoker is going to install #{install_packages} on this machine."\
            " It is also going to install#{install_other} a socat service"\
            " which will forward all local requests on port 80 and 443 to another port")
          Invoker::Logger.puts("If you still want to proceed with installation, press y.")
          Invoker::CLI::Question.agree("Proceed with installation (y/n) : ")
        end
      end
    end
  end
end
