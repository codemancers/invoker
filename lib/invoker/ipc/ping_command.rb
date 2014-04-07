module Invoker
  module IPC
    class PingCommand < BaseCommand
      def run_command(message_object)
        pong = Invoker::IPC::Message::Pong.new(status: 'pong')
        send_data(pong)
      end
    end
  end
end
