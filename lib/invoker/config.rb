require "yaml"
require 'iniparse'

module Invoker
  class Config
    attr_accessor :processes
    def initialize(filename)
      @ini_content = File.read(filename)
      @processes = process_ini(@ini_content)
    end

    private
    def process_ini(ini_content)
      document = IniParse.parse(ini_content)
      document.map do |section|
        check_directory(section["directory"])
        OpenStruct.new(label: section.key, dir: section["directory"], cmd: section["command"])
      end
    end

    def check_directory(app_dir)
      if app_dir && !app_dir.empty? && !File.directory?(app_dir)
        raise Invoker::Errors::InvalidConfig.new("Invalid directory #{app_dir}")
      end
    end

  end
end
