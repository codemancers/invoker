module Invoker
  module Power
    # for migrating existins users to pf
    class PfMigrate
      def firewall_config_requires_migration?
        return false if !Invoker.darwin?
        require 'facter'
        # lets not migrate on osx < 10.10
        return false if osx_version < "10.10"
        # also verify if firewall config is old
        check_firewall_file?
      end

      def migrate
        if firewall_config_requires_migration? && ask_user_for_migration
          sudome
          osx_setup = Invoker::Power::OsxSetup.new()
          osx_setup.install_firewall(Invoker.config.http_port, Invoker.config.https_port)
          drop_to_normal_user
          Invoker::Logger.puts "Invoker has updated its configuration for yosemite."\
            " Please restart OSX to complete the configuration process."
          exit(-1)
        end
      end

      def ask_user_for_migration
        if not_already_root?
          Invoker::Logger.puts "Invoker has detected you are running OSX 10.10 "\
            " but your invoker configuration does not support it."
          Invoker::Logger.puts "Invoker can update its configuration automaticaly"\
            " but it will require a system reboot."
          Invoker::CLI::Question.agree("Update Invoker configuration (y/n) :")
        else
          true
        end
      end

      # http://jimeh.me/blog/2010/02/22/built-in-sudo-for-ruby-command-line-tools/
      def sudome
        if not_already_root?
          exec("sudo #{$0} #{ARGV.join(' ')}")
        end
      end

      def not_already_root?
        ENV["USER"] != "root"
      end

      def drop_to_normal_user
        EventMachine.set_effective_user(ENV["SUDO_USER"])
      end

      def osx_version
        Facter.to_hash["macosx_productversion"]
      end

      def check_firewall_file?
        return false unless File.exist?(Invoker::Power::OsxSetup::FIREWALL_PLIST_FILE)
        firewall_contents = File.read(Invoker::Power::OsxSetup::FIREWALL_PLIST_FILE)
        !!firewall_contents.match(/ipfw/)
      end
    end
  end
end
