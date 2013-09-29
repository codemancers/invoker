require "spec_helper"

require "tempfile"

describe "Invoker::Config" do
  describe "with invalid directory" do
    it "should raise error during startup" do
      begin
        file = Tempfile.new("invalid_config.ini")

        config_data =<<-EOD
[try_sleep]
directory = /Users/gnufied/foo
command = ruby try_sleep.rb
      EOD
        file.write(config_data)
        file.close
        lambda {
          Invoker::Parsers::Config.new(file.path, 9000)
        }.should.raise(Invoker::Errors::InvalidConfig)
      ensure
        file.unlink()
      end
    end
  end

  describe "for ports" do
    it "should replace port in commands" do
      begin
        file = Tempfile.new("invalid_config.ini")

        config_data =<<-EOD
[try_sleep]
directory = /tmp
command = ruby try_sleep.rb -p $PORT

[ls]
directory = /tmp
command = ls -p $PORT

[noport]
directory = /tmp
command = ls
      EOD
        file.write(config_data)
        file.close

        config = Invoker::Parsers::Config.new(file.path, 9000)
        command1 = config.processes.first

        command1.port.should == 9001
        command1.cmd.should =~ /9001/

        command2 = config.processes[1]

        command2.port.should == 9002
        command2.cmd.should =~ /9002/

        command2 = config.processes[2]

        command2.port.should == nil
      ensure
        file.unlink()
      end
    end
  end
end
