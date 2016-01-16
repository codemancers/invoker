module Invoker
  module Power
    module Distro
      class Arch < Base
        def install_required_software
          system("pacman -S --needed --noconfirm dnsmasq socat")
          system("mkdir -p /etc/dnsmasq.d")
          unless File.open("/etc/dnsmasq.conf").each_line.any? { |line| line.chomp == "conf-dir=/etc/dnsmasq.d" }
            File.open("/etc/dnsmasq.conf", "a") {|f| f.write("conf-dir=/etc/dnsmasq.d") }
          end
        end
      end
    end
  end
end
