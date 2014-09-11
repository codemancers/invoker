module Invoker
  module Power
    module Distro
      class Arch < Base
        def install_required_software
          system("pacman -S --needed --noconfirm dnsmasq")
          system("mkdir -p /etc/dnsmasq.d")
          unless File.open("/etc/dnsmasq.conf").each_line.any? { |line| line.chomp == "conf-dir=/etc/dnsmasq.d" }
            File.open("/etc/dnsmasq.conf", "a") {|f| f.write("conf-dir=/etc/dnsmasq.d") }
          end
          unless system("ls /usr/bin/rinetd > /dev/null 2>&1")
            fail "You'll need to install rinetd from the AUR in order to continue"
          end
        end
      end
    end
  end
end
