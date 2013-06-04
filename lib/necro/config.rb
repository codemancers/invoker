require "yaml"

module Necro
  class Config
    attr_accessor :processes
    def initialize(filename)
      @yaml_content = File.read(filename)
      @processes = YAML.load(@yaml_content)['processes'].map do |key,process_info|
        OpenStruct.new(label: key, dir: process_info['directory'], cmd: process_info['command'])
      end
    end
  end
end
