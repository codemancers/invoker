module Invoker
  module Power
    module Distro
      class Redhat < Base
        def install_required_software
          system("yum --assumeyes install dnsmasq rinetd")
        end

        def restart_services
          system("systemctl enable rinetd")
          system("service rinetd restart")
          system("service dnsmasq restart")
        end
      end
    end
  end
end
