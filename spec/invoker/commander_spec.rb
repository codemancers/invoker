require "spec_helper"

describe "Invoker::Commander" do

  describe "With no processes configured" do
    before do
      @commander = Invoker::Commander.new()
    end

    it "should throw error" do
      invoker_config.stubs(:processes).returns([])

      expect {
        @commander.start_manager()
      }.to raise_error(Invoker::Errors::InvalidConfig)
    end
  end

  describe "#add_command_by_label" do
    before do
      @commander = Invoker::Commander.new()
    end

    it "should find command by label and start it, if found" do
      invoker_config.stubs(:processes).returns([OpenStruct.new(:label => "resque", :cmd => "foo", :dir => "bar")])
      invoker_config.expects(:process).returns(OpenStruct.new(:label => "resque", :cmd => "foo", :dir => "bar"))
      @commander.expects(:add_command).returns(true)

      @commander.add_command_by_label("resque")
    end

    it "should not start already running process" do
      @commander.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
      expect(@commander.add_command_by_label("resque")).to be_false
    end
  end

  describe "#remove_command" do
    describe "when a worker is found" do
      before do
        @commander = Invoker::Commander.new()
        @commander.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
      end

      describe "if a signal is specified" do
        it "should use that signal to kill the worker" do
          @commander.expects(:process_kill).with("bogus", "HUP").returns(true)
          expect(@commander.remove_command("resque", "HUP")).to be_true
        end
      end

      describe "if no signal is specified" do
        it "should use INT signal" do
          @commander.expects(:process_kill).with("bogus", "INT").returns(true)
          expect(@commander.remove_command("resque", nil)).to be_true
        end
      end

      # describe "when a worker is not found" do
      #   before do
      #     @commander = Invoker::Commander.new()
      #     @commander.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
      #   end

      #   it "should return false" do

      #   end
      # end
    end

    describe "when no worker is found" do
      before do
        @commander = Invoker::Commander.new()
        @commander.workers.expects(:[]).returns(nil)
      end

      it "should not kill anything" do
        @commander.expects(:process_kill).never()
        @commander.remove_command("resque", "HUP")
      end
    end

  end

  describe "#add_command" do
    before do
      invoker_config.stubs(:processes).returns([OpenStruct.new(:label => "sleep", :cmd => "sleep 4", :dir => ENV['HOME'])])
      @commander = Invoker::Commander.new()
      Invoker.const_set(:COMMANDER, @commander)
    end

    after do
      Invoker.send(:remove_const,:COMMANDER)
    end

    it "should populate workers and open_pipes" do
      @commander.expects(:start_event_loop)
      @commander.start_manager()
      expect(@commander.open_pipes).not_to be_empty
      expect(@commander.workers).not_to be_empty

      worker = @commander.workers['sleep']

      expect(worker).not_to be_nil
      expect(worker.command_label).to eq('sleep')
      expect(worker.color).to eq(:green)

      pipe_end_worker = @commander.open_pipes[worker.pipe_end.fileno]
      expect(pipe_end_worker).not_to be_nil
    end
  end

  describe "#runnables" do
    before do
      @commander = Invoker::Commander.new()
    end

    it "should run runnables in reactor tick with one argument" do
      @commander.on_next_tick("foo") { |cmd| add_command_by_label(cmd) }
      @commander.expects(:add_command_by_label).returns(true)
      @commander.run_runnables()
    end

    it "should run runnables with multiple args" do
      @commander.on_next_tick("foo", "bar", "baz") { |t1,*rest|
        remove_command(t1, rest)
      }
      @commander.expects(:remove_command).with("foo", ["bar", "baz"]).returns(true)
      @commander.run_runnables()
    end

    it "should run runnable with no args" do
      @commander.on_next_tick() { hello() }
      @commander.expects(:hello).returns(true)
      @commander.run_runnables()
    end
  end

end
