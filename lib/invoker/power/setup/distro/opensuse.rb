module Invoker
  module Power
    module Distro
      class Opensuse < Base
        def install_required_software
          system("zypper install -l dnsmasq socat")
        end
      end
    end
  end
end
