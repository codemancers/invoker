module MockSetupFile
  def setup_mocked_config_files
    setup_invoker_config
    setup_osx_resolver_path
  end

  def remove_mocked_config_files
    restore_invoker_config
    restore_osx_resolver_setup
  end

  private

  def setup_invoker_config
    @old_config = Invoker::Power::Config::CONFIG_LOCATION
    Invoker::Power::Config.const_set(:CONFIG_LOCATION, "/tmp/.invoker/config")
    safe_make_directory("/tmp/.invoker")
    safe_remove_file(Invoker::Power::Config::CONFIG_LOCATION)
  end

  def restore_invoker_config
    safe_remove_file(Invoker::Power::Config::CONFIG_LOCATION)
    Invoker::Power::Config.const_set(:CONFIG_LOCATION, @old_config)
    $VERBOSE = @original_verbosity
  end

  def restore_osx_resolver_setup
    safe_remove_file(Invoker::Power::OsxSetup::RESOLVER_FILE)
    FileUtils.rm_rf(Invoker::Power::OsxSetup::RESOLVER_DIR)
    Invoker::Power::OsxSetup.const_set(:RESOLVER_FILE, @old_resolver)
  end

  def setup_osx_resolver_path
    @old_resolver = Invoker::Power::OsxSetup::RESOLVER_FILE
    Invoker::Power::OsxSetup.const_set(:RESOLVER_FILE, "/tmp/resolver/invoker-dev")
    Invoker::Power::OsxSetup.const_set(:RESOLVER_DIR, "/tmp/resolver")

    safe_make_directory(Invoker::Power::OsxSetup::RESOLVER_DIR)
    safe_remove_file(Invoker::Power::OsxSetup::RESOLVER_FILE)
  end

  def safe_remove_file(file_location)
    File.exist?(file_location) &&
      File.delete(file_location)
  end

  def safe_make_directory(directory)
    FileUtils.mkdir(directory) unless Dir.exist?(directory)
  end
end
