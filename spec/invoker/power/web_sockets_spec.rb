require 'spec_helper'

def websocket_server
  require 'websocket-eventmachine-server'

  EM.run do
    WebSocket::EventMachine::Server.start(host: "0.0.0.0", port: 28080) do |ws|
      ws.onerror { |e| p e }
      ws.onmessage { ws.send "pong" }
    end

    EM.add_timer(2) { EM.stop }
  end
end

def websocket_client
  require 'websocket-eventmachine-client'

  @message = ""

  EM.run do
    ws = WebSocket::EventMachine::Client.connect(uri: 'ws://0.0.0.0:28080')
    ws.onerror { |e| p e }
    ws.onopen { ws.send("ping") }
    ws.onmessage { |m, _| @message = m }

    EM.add_timer(2) do
      expect(@message).to eq "pong"
      EM.stop
    end
  end
end

# Full integration test. Start a server, and client. Let client
# interact with server do a ping-pong.
describe 'Web sockets support' do
  it 'can ping pong via balancer' do
    server = fork { websocket_server }
    client = fork { websocket_client }
    Process.waitall
  end
end
