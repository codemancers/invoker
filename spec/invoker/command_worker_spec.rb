require "spec_helper"

describe "Command Worker" do
  let(:pipe_end) { StringIO.new }
  let(:command_worker) { Invoker::CommandWorker.new('rails', pipe_end, 100, :red) }

  describe "converting workers hash to json" do
    before do
      @workers = {}
      @workers["foo"] = Invoker::CommandWorker.new("foo", 89, 1023, "red")
      @workers["bar"] = Invoker::CommandWorker.new("bar", 99, 1024, "blue")
    end

    it "should print json" do
      expect(@workers.values.map {|worker| worker.to_h }.to_json).not_to be_empty
    end
  end

  describe "sending json responses" do
    before do
      @socket = StringIO.new
      Invoker.tail_watchers = Invoker::CLI::TailWatcher.new
      Invoker.tail_watchers.add(['rails'], @socket)
    end

    after do
      Invoker.tail_watchers = nil
    end

    context "when there is a error encoding the message" do
      it "should send nothing to the socket" do
        MM::TailResponse.any_instance.expects(:encoded_message).raises(StandardError, "encoding error")
        command_worker.receive_line('hello_world')
        expect(@socket.string).to be_empty
      end
    end

    context "when there is successful delivery" do
      it "should return json data to client if tail watchers" do
        command_worker.receive_line('hello_world')
        expect(@socket.string).to match(/hello_world/)
      end
    end
  end
end
