module Invoker
  module Power
    # for migrating existins users to pf
    class PfMigrate
      def firewall_config_requires_migration?
        return false if !Invoker.darwin?
        false
      end

      def migrate
        if firewall_config_requires_migration?
          sudome
          osx_setup = Invoker::Power::OsxSetup.new()
          osx_setup.install_firewall(Invoker.config.http_port, Invoker.config.https_port)
          EventMachine.set_effective_user(ENV["SUDO_USER"])
          Invoker::Logger.puts "Invoker has updated its configuration for yosemite."\
            " Please restart OSX to complete the configuration process."
          exit(=1)
        end
      end

      def sudome
        if ENV["USER"] != "root"
          exec("sudo #{ENV['_']} #{ARGV.join(' ')}")
        end
      end
    end
  end
end
