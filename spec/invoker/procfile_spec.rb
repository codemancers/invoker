require 'spec_helper'

describe Invoker::Parsers::Procfile do
  context "parsing . in process labels" do
    it "should parse them correctly" do
      begin
        filename = "/tmp/Procfile"
        file = File.open(filename, "w")
        config_data = <<-EOD
foo: bundle exec rails s
foo.bar: node bar.js
        EOD
        file.write(config_data)
        file.close

        config = Invoker::Parsers::Config.new(filename, 9000)
        expect(config.processes.length).to eq(2)
      ensure
        File.unlink(filename)
      end
    end
  end
end
