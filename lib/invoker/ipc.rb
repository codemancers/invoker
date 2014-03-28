require "invoker/ipc/base_command"
require 'invoker/ipc/message'
require 'invoker/ipc/add_command'
require 'invoker/ipc/add_http_command'
require 'invoker/ipc/client_handler'
require 'invoker/ipc/dns_check_command'
require 'invoker/ipc/list_command'
require 'invoker/ipc/remove_command'
require 'invoker/ipc/server'
require "invoker/ipc/reload_command"
require 'invoker/ipc/tail_command'
require 'invoker/ipc/unix_client'

module Invoker
  module IPC
    INITIAL_PACKET_SIZE = 9
    def self.message_from_io(io)
      json_size = io.read(INITIAL_PACKET_SIZE)
      json_string = io.read(json_size.to_i)
      ruby_object_hash = JSON.parse(json_string)
      command_name = camelize(ruby_object_hash['type'])
      command_klass = Invoker::IPC::Message.const_get(command_name)
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
