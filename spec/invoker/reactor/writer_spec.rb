require "spec_helper"

describe Invoker::Reactor::Writer do
  let(:writer) { Invoker::Reactor::Writer.new }
  let(:socket) { StringIO.new }

  before do
    socket.stubs(:fileno).returns(100)
  end

  describe "should allow writing data" do
    it "should write data given a socket" do
      writer.send_data(socket, "hello world")
      expect(socket.string).to eql "hello world"
      expect(writer.pending_writes).to be_empty
    end

    it "should schedule the write if not written at once" do
      socket.expects(:write_nonblock).returns(5)
      writer.send_data(socket, "hello world")

      expect(writer.pending_writes).to_not be_empty
      yet_to_be_written = writer.pending_writes.values.first[:data]
      expect(yet_to_be_written).to eql " world"
      expect(writer.write_array).to_not be_empty
    end
  end

  describe "handling write ready sockets" do
    it "should handle pending writes sockets" do
      writer.pending_writes[100] = { data: "hello", socket: socket }

      writer.handle_write_event([socket])

      expect(writer.write_array).to be_empty
      expect(socket.string).to eql "hello"
      expect(writer.pending_writes).to be_empty
    end

    it "should handle error if write fails" do
      writer.pending_writes[100] = { data: "hello", socket: socket }
      socket.expects(:write_nonblock).raises(Errno::EPIPE)
      socket.expects(:close)
      writer.handle_write_event([socket])
      expect(writer.write_array).to be_empty
      expect(writer.pending_writes).to be_empty
    end
  end
end
