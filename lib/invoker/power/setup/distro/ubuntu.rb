require "invoker/power/setup/distro/debian"

module Invoker
  module Power
    module Distro
      class Ubuntu < Debian
        def using_systemd_resolved?
          return @_using_systemd_resolved if defined?(@_using_systemd_resolved)
          @_using_systemd_resolved = system("systemctl is-active --quiet systemd-resolved")
        end

        def install_required_software
          if using_systemd_resolved?
            # Don't install dnsmasq if Ubuntu version uses systemd-resolved for DNS because they conflict
            system("apt-get --assume-yes install socat")
          else
            super
          end
        end

        def install_packages
          using_systemd_resolved? ? "socat" : super
        end

        def install_other
          using_systemd_resolved? ? nil : super
        end

        def resolver_file
          using_systemd_resolved? ? nil : super
        end

        def tld
          using_systemd_resolved? ? 'localhost' : @tld
        end

        def get_user_confirmation?
          if using_systemd_resolved? && tld != 'localhost'
            Invoker::Logger.puts("Ubuntu installations using systemd-resolved (typically Ubuntu 17+) only support the .localhost domain, so your tld setting (or the default) will be ignored.".colorize(:yellow))
          end
          super
        end
      end
    end
  end
end
