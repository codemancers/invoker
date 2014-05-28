module Invoker
  module Power
    module Distro
      class Base
        RESOLVER_FILE = "/etc/dnsmasq.d/dev-tld"
        RINETD_FILE = "/etc/rinetd.conf"

        def self.distro_installer
          case Facter[:operatingsystem].value
          when "Ubuntu"
            require "invoker/power/setup/distro/ubuntu"
            Ubuntu.new
          when "Fedora"
            require "invoker/power/setup/distro/redhat"
            Redhat.new
          else
            raise "Your selected distro is not supported by Invoker"
          end
        end

        def resolver_file
          RESOLVER_FILE
        end

        def rinetd_file
          RINETD_FILE
        end

        # Install required software
        def install_required_software
          raise "Unimplemented"
        end

        def restart_services
          system("service rinetd restart")
          system("service dnsmasq restart")
        end
      end
    end
  end
end
