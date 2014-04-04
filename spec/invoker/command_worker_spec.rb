require "spec_helper"

describe "Command Worker" do
  let(:reactor) { mock }
  describe "converting workers hash to json" do
    before do
      @workers = {}
      @workers["foo"] = Invoker::CommandWorker.new("foo", 89, 1023, "red", reactor)
      @workers["bar"] = Invoker::CommandWorker.new("bar", 99, 1024, "blue", reactor)
    end

    it "should print json" do
      expect(@workers.values.map {|worker| worker.to_h }.to_json).not_to be_empty
    end
  end
end
