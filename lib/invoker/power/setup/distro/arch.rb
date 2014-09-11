module Invoker
  module Power
    module Distro
      class Arch < Base
        def install_required_software
          system("pacman -S --needed --noconfirm dnsmasq")
          system("mkdir -p /etc/dnsmasq.d")
          unless system("ls /usr/bin/rinetd")
            fail "You'll need to install rinetd from the AUR in order to continue"
          end
        end
      end
    end
  end
end
