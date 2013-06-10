require "yaml"
require 'iniparse'

module Invoker
  class Config
    attr_accessor :processes
    def initialize(filename)
      @ini_content = File.read(filename)
      @processes = process_ini(@ini_content)
    end

    def process_ini(ini_content)
      document = IniParse.parse(ini_content)
      document.map do |section|
        OpenStruct.new(label: section.key, dir: section["directory"], cmd: section["command"])
      end
    end
  end
end
