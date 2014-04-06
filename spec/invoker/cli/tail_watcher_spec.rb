require "spec_helper"

describe  Invoker::CLI::TailWatcher do
  let(:tail_watcher) { Invoker::CLI::TailWatcher.new }

  describe "Adding processes to watch list" do
    it "should allow add" do
      tail_watcher.add(["rails"], "socket")
      expect(tail_watcher.tail_watchers).to_not be_empty
      expect(tail_watcher["rails"]).to eql ["socket"]
    end
  end

  describe "removing processes from watch list" do
    context "when process has only one watcher" do
      before do
        tail_watcher.add(["rails"], "socket")
      end
      it "should remove and purge process watch list" do
        expect(tail_watcher.tail_watchers).to_not be_empty
        tail_watcher.remove("rails", "socket")
        expect(tail_watcher.tail_watchers).to be_empty
      end
    end
    context "when process multiple watchers" do
      before do
        tail_watcher.add(["rails"], "socket")
        tail_watcher.add(["rails"], "socket2")
      end

      it "should remove only related socket" do
        expect(tail_watcher.tail_watchers).to_not be_empty
        tail_watcher.remove("rails", "socket")
        expect(tail_watcher.tail_watchers).to_not be_empty
        expect(tail_watcher["rails"]).to eql ["socket2"]
      end
    end
  end
end
