require "spec_helper"

require "tempfile"

describe "Invoker::Config" do
  describe "with invalid directory" do
    it "should raise error during startup" do
      begin
        file = Tempfile.new(["invalid_config", ".ini"])

        config_data =<<-EOD
[try_sleep]
directory = /Users/gnufied/foo
command = ruby try_sleep.rb
      EOD
        file.write(config_data)
        file.close
        expect {
          Invoker::Parsers::Config.new(file.path, 9000)
        }.to raise_error(Invoker::Errors::InvalidConfig)
      ensure
        file.unlink()
      end
    end
  end

  describe "for ports" do
    it "should replace port in commands" do
      begin
        file = Tempfile.new(["invalid_config", ".ini"])

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

        expect(command1.port).to eq(9001)
        expect(command1.cmd).to match(/9001/)

        command2 = config.processes[1]

        expect(command2.port).to eq(9002)
        expect(command2.cmd).to match(/9002/)

        command2 = config.processes[2]

        expect(command2.port).to be_nil
      ensure
        file.unlink()
      end
    end

    it "should use port from separate option" do
      begin
        file = Tempfile.new(["invalid_config", ".ini"])
        config_data =<<-EOD
[try_sleep]
directory = /tmp
command = ruby try_sleep.rb -p $PORT

[ls]
directory = /tmp
port = 3000
command = pwd

[noport]
directory = /tmp
command = ls
      EOD
        file.write(config_data)
        file.close

        config = Invoker::Parsers::Config.new(file.path, 9000)
        command1 = config.processes.first

        expect(command1.port).to eq(9001)
        expect(command1.cmd).to match(/9001/)

        command2 = config.processes[1]

        expect(command2.port).to eq(3000)

        command2 = config.processes[2]

        expect(command2.port).to be_nil
      ensure
        file.unlink()
      end
    end
  end

  describe "loading power config" do
    before do
      @file = Tempfile.new(["config", ".ini"])
    end

    it "does not load config if platform is not darwin" do
      Invoker.expects(:darwin?).returns(false)
      Invoker::Power::Config.expects(:load_config).never
      Invoker::Parsers::Config.new(@file.path, 9000)
    end

    it "does not load config if platform is darwin but there is no power config file" do
      Invoker.expects(:darwin?).returns(true)
      Invoker::Power::Config.expects(:load_config).never
      Invoker::Parsers::Config.new(@file.path, 9000)
    end

    it "loads config if platform is darwin and power config file exists" do
      Invoker.expects(:darwin?).returns(true)
      File.open(Invoker::Power::Config::CONFIG_LOCATION, "w") { |fl| fl.puts "sample" }
      Invoker::Power::Config.expects(:load_config).once
      Invoker::Parsers::Config.new(@file.path, 9000)
    end
  end

  describe "Procfile" do
    it "should load Procfiles and create config object" do
      begin
        File.open("/tmp/Procfile", "w") {|fl| 
          fl.write <<-EOD
web: bundle exec rails s -p $PORT
          EOD
        }
        config = Invoker::Parsers::Config.new("/tmp/Procfile", 9000)
        command1 = config.processes.first

        expect(command1.port).to eq(9001)
        expect(command1.cmd).to match(/bundle exec rails/)
      ensure
        File.delete("/tmp/Procfile")
      end
    end
  end

  describe "Copy of DNS information" do
    it "should allow copy of DNS information" do
      begin
        File.open("/tmp/Procfile", "w") {|fl| 
          fl.write <<-EOD
web: bundle exec rails s -p $PORT
          EOD
        }
        Invoker.load_invoker_config("/tmp/Procfile", 9000)
        dns_cache = Invoker::DNSCache.new(Invoker.config)

        expect(dns_cache.dns_data).to_not be_empty
        expect(dns_cache.dns_data['web']).to_not be_empty
        expect(dns_cache.dns_data['web']['port']).to eql 9001
      ensure
        File.delete("/tmp/Procfile")
      end
    end
  end

end
