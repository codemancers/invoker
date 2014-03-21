module Invoker
  module IPC
    def self.message_from_io(io)
      yajl_parser = Yajl::Parser.new
      ruby_object_hash = yajl_parser.parse(io)
      command_name = ruby_object_hash['command']
      command_klass = Invoker::IPC.const_set(command_name.capitalize)
      command_klass.new(ruby_object_hash)
    end

    # Taken from Rails without inflection support
    def self.camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      string.gsub!('/', '::')
      string
    end

    def self.underscore(term)
      word = term.to_s.gsub('::', '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end

require 'invoker/ipc/message'
require 'invoker/ipc/add'
require 'invoker/ipc/client'
require 'invoker/ipc/dns_check'
require 'invoker/ipc/list'
require 'invoker/ipc/remove'
require 'invoker/ipc/server'
require 'invoker/ipc/stop'
require 'invoker/ipc/tail'
