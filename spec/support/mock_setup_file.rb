require 'securerandom'

module MockSetupFile
  def setup_mocked_config_files
    setup_invoker_config
    setup_osx_resolver_path
    setup_linux_resolver_path
    setup_socket_path
  end

  def remove_mocked_config_files
    restore_invoker_config
    restore_osx_resolver_setup
    restore_linux_resolver_path
    restore_socket_path
  end

  def safe_remove_file(file_location)
    File.exist?(file_location) &&
      File.delete(file_location)
  end

  def safe_make_directory(directory)
    FileUtils.mkdir(directory) unless Dir.exist?(directory)
  end

  private

  def setup_invoker_config
    Invoker::Power::Config.stubs(:config_file).returns("/tmp/.invoker/config")
    Invoker::Power::Config.stubs(:config_dir).returns("/tmp/.invoker")
    safe_make_directory("/tmp/.invoker")
    safe_remove_file(Invoker::Power::Config.config_file)
  end

  def restore_invoker_config
    safe_remove_file("/tmp/.invoker/config")
  end

  def restore_osx_resolver_setup
    safe_remove_file(Invoker::Power::OsxSetup.resolver_file)
    FileUtils.rmdir(Invoker::Power::OsxSetup.resolver_dir)

    Invoker::Power::OsxSetup.reset_resolver_dir
    Invoker::Power::OsxSetup.reset_resolver_file_name
  end

  def setup_osx_resolver_path
    Invoker::Power::OsxSetup.resolver_dir = '/tmp/resolver'
    Invoker::Power::OsxSetup.resolver_file_name = 'invoker-dev'

    safe_make_directory(Invoker::Power::OsxSetup::resolver_dir)
    safe_remove_file(Invoker::Power::OsxSetup::resolver_file)
  end

  def setup_socket_path
    @old_socket_path = Invoker::IPC::Server::SOCKET_PATH
    socket_uuid = SecureRandom.urlsafe_base64
    Invoker::IPC::Server.const_set(:SOCKET_PATH, "/tmp/invoker-#{socket_uuid}")
  end

  def restore_socket_path
    Invoker::IPC::Server.const_set(:SOCKET_PATH, @old_socket_path)
  end

  def setup_linux_resolver_path
    @old_socat_script = Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT
    @old_socat_unit = Invoker::Power::Distro::Base::SOCAT_SYSTEMD
    Invoker::Power::Distro::Base.resolver_file = "/tmp/dev-tld"
    Invoker::Power::Distro::Base.const_set(:SOCAT_SHELLSCRIPT, "/tmp/invoker_forwarder.sh")
    Invoker::Power::Distro::Base.const_set(:SOCAT_SYSTEMD, "/tmp/socat_invoker.service")
  end

  def restore_linux_resolver_path
    safe_remove_file(Invoker::Power::Distro::Base.resolver_file)
    safe_remove_file(Invoker::Power::Distro::Base::SOCAT_SHELLSCRIPT)
    safe_remove_file(Invoker::Power::Distro::Base::SOCAT_SYSTEMD)

    Invoker::Power::Distro::Base.reset_resolver_file
    Invoker::Power::Distro::Base.const_set(:SOCAT_SHELLSCRIPT, @old_socat_script)
    Invoker::Power::Distro::Base.const_set(:SOCAT_SYSTEMD, @old_socat_unit)
  end
end
