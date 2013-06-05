require "yaml"
require 'iniparse'

module Necro
  class Config
    attr_accessor :processes
    def initialize(filename)
      @ini_content = File.read(filename)
      @processes = process_ini(@ini_content)
    end

    def process_yaml(yaml_content)
      YAML.load(yaml_content)['processes'].map do |key,process_info|
        OpenStruct.new(label: key, dir: process_info['directory'], cmd: process_info['command'])
      end
    end

    def process_ini(ini_content)
      document = IniParse.parse(ini_content)
      document.map do |section|
        OpenStruct.new(label: section.key, dir: section["directory"], cmd: section["command"])
      end
    end
  end
end
