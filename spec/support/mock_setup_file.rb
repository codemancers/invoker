module MockSetupFile
  def setup_mocked_config_files
    setup_invoker_config
    setup_osx_resolver_path
    setup_linux_resolver_path
  end

  def remove_mocked_config_files
    restore_invoker_config
    restore_osx_resolver_setup
    restore_linux_resolver_path
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
    safe_remove_file(Invoker::Power::OsxSetup::RESOLVER_FILE)
    FileUtils.rm_rf(Invoker::Power::OsxSetup::RESOLVER_DIR)
    Invoker::Power::OsxSetup.const_set(:RESOLVER_FILE, @old_osx_resolver)
  end

  def setup_osx_resolver_path
    @old_osx_resolver = Invoker::Power::OsxSetup::RESOLVER_FILE
    Invoker::Power::OsxSetup.const_set(:RESOLVER_FILE, "/tmp/resolver/invoker-dev")
    Invoker::Power::OsxSetup.const_set(:RESOLVER_DIR, "/tmp/resolver")

    safe_make_directory(Invoker::Power::OsxSetup::RESOLVER_DIR)
    safe_remove_file(Invoker::Power::OsxSetup::RESOLVER_FILE)
  end

  def setup_linux_resolver_path
    @old_linux_resolver = Invoker::Power::Distro::Base::RESOLVER_FILE
    @old_rinetd_config = Invoker::Power::Distro::Base::RINETD_FILE
    Invoker::Power::Distro::Base.const_set(:RESOLVER_FILE, "/tmp/dev-tld")
    Invoker::Power::Distro::Base.const_set(:RINETD_FILE, "/tmp/rinetd.conf")
  end

  def restore_linux_resolver_path
    safe_remove_file(Invoker::Power::Distro::Base::RESOLVER_FILE)
    safe_remove_file(Invoker::Power::Distro::Base::RINETD_FILE)
    Invoker::Power::Distro::Base.const_set(:RESOLVER_FILE, @old_linux_resolver)
    Invoker::Power::Distro::Base.const_set(:RINETD_FILE, @old_rinetd_config)
  end
end
