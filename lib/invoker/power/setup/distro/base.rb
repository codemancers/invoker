module Invoker
  module Power
    module Distro
      class Base
        SOCAT_SHELLSCRIPT = "/usr/bin/invoker_forwarder.sh"
        SOCAT_SYSTEMD = "/etc/systemd/system/socat_invoker.service"

        class << self
          # @!group Helpers for use in tests

          def resolver_file=(resolver_file)
            @@resolver_file = resolver_file
          end

          def reset_resolver_file
            @@resolver_file = nil
          end

          # @!endgroup

          def resolver_file
            begin
              return @@resolver_file if @@resolver_file
            rescue NameError
            end
            "/etc/dnsmasq.d/#{Invoker::Power.tld_value}-tld"
          end
        end

        def self.distro_installer
          case Facter[:operatingsystem].value
          when "Ubuntu"
            require "invoker/power/setup/distro/ubuntu"
            Ubuntu.new
          when "Fedora"
            require "invoker/power/setup/distro/redhat"
            Redhat.new
          when "Archlinux"
            require "invoker/power/setup/distro/arch"
            Arch.new
          when "Debian"
            require "invoker/power/setup/distro/debian"
            Debian.new
          when "LinuxMint"
            require "invoker/power/setup/distro/mint"
            Mint.new
          when "OpenSuSE"
            require "invoker/power/setup/distro/opensuse"
            Opensuse.new
          else
            raise "Your selected distro is not supported by Invoker"
          end
        end

        def resolver_file
          self.class.resolver_file
        end

        def socat_script
          SOCAT_SHELLSCRIPT
        end

        def socat_systemd
          SOCAT_SYSTEMD
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
