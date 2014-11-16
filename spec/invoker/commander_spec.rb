require "spec_helper"

describe "Invoker::Commander" do
  describe "With no processes configured" do
    before do
      @commander = Invoker::Commander.new
    end

    it "should throw error" do
      invoker_config.stubs(:processes).returns([])

      expect {
        @commander.start_manager
      }.to raise_error(Invoker::Errors::InvalidConfig)
    end
  end

  describe "#start_process" do
    describe "when not daemonized" do
      before do
        invoker_config.stubs(:processes).returns(
          [OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME'])]
        )
        @commander = Invoker::Commander.new
        Invoker.commander = @commander
      end

      after do
        Invoker.commander = nil
      end

      it "should populate workers and open_pipes" do
        @commander.expects(:start_event_loop)
        @commander.process_manager.expects(:load_env).returns({})
        @commander.process_manager.expects(:spawn).returns(100)
        @commander.process_manager.expects(:wait_on_pid)
        @commander.expects(:at_exit)
        @commander.start_manager
        expect(@commander.process_manager.open_pipes).not_to be_empty
        expect(@commander.process_manager.workers).not_to be_empty

        worker = @commander.process_manager.workers['foobar']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('foobar')

        pipe_end_worker = @commander.process_manager.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end

    describe "when daemonized" do
      before do
        invoker_config.stubs(:processes).returns(
          [OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME'])]
        )
        @commander = Invoker::Commander.new
        Invoker.commander = @commander
        Invoker.daemonize = true
      end

      after do
        Invoker.commander = nil
        Invoker.daemonize = false
      end

      it "should daemonize the process and populate workers and open_pipes" do
        @commander.expects(:start_event_loop)
        @commander.process_manager.expects(:load_env).returns({})
        Invoker.daemon.expects(:start).once
        @commander.process_manager.expects(:spawn).returns(100)
        @commander.process_manager.expects(:wait_on_pid)
        @commander.expects(:at_exit)
        @commander.start_manager

        expect(@commander.process_manager.open_pipes).not_to be_empty
        expect(@commander.process_manager.workers).not_to be_empty

        worker = @commander.process_manager.workers['foobar']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('foobar')

        pipe_end_worker = @commander.process_manager.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end
  end

  describe 'autostart' do
    context "a process can't be autostarted" do
      before do
        @processes = [
          OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME']),
          OpenStruct.new(:label => "panda", :cmd => "panda_command", :dir => ENV['HOME'], :autostart => false)
        ]
        invoker_config.stubs(:processes).returns(@processes)
        autostartable_processes = [OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME'])]
        invoker_config.stubs(:autostartable_processes).returns(autostartable_processes)

        @commander = Invoker::Commander.new
      end

      it "doesn't start process" do
        @commander.expects(:install_interrupt_handler)
        @commander.process_manager.expects(:run_power_server)
        @commander.expects(:at_exit)
        @commander.expects(:start_event_loop)

        @commander.process_manager.expects(:start_process).with(@processes[0])
        @commander.process_manager.expects(:start_process).with(@processes[1]).never
        @commander.start_manager
      end
    end
  end

  describe "#runnables" do
    before do
      @commander = Invoker::Commander.new
    end

    it "should run runnables in reactor tick with one argument" do
      @commander.on_next_tick("foo") { |cmd| start_process_by_name(cmd) }
      @commander.expects(:start_process_by_name).returns(true)
      @commander.run_runnables()
    end

    it "should run runnables with multiple args" do
      @commander.on_next_tick("foo", "bar", "baz") { |t1,*rest|
        stop_process(t1, rest)
      }
      @commander.expects(:stop_process).with("foo", ["bar", "baz"]).returns(true)
      @commander.run_runnables()
    end

    it "should run runnable with no args" do
      @commander.on_next_tick() { hello() }
      @commander.expects(:hello).returns(true)
      @commander.run_runnables()
    end
  end
end
