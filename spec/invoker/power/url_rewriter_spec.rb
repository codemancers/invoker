require 'spec_helper'

describe Invoker::Power::UrlRewriter do
  let(:rewriter) { Invoker::Power::UrlRewriter.new }

  context "matching domain part of incoming request" do
    before(:all) do
      @original_invoker_config = Invoker.config

      Invoker.config = mock
      Invoker.config.stubs(:tld).returns("local")
    end

    after(:all) do
      Invoker.config = @original_invoker_config
    end

    it "should match foo.local" do
      match = rewriter.extract_host_from_domain("foo.local")
      expect(match).to_not be_empty

      matching_string = match[0]
      expect(matching_string).to eq("foo")
    end

    it "should match foo.local:1080" do
      match = rewriter.extract_host_from_domain("foo.local:1080")
      expect(match).to_not be_empty

      matching_string = match[0]
      expect(matching_string).to eq("foo")
    end

    it "should match emacs.bar.local" do
      match = rewriter.extract_host_from_domain("emacs.bar.local")
      expect(match).to_not be_empty

      expect(match[0]).to eq("emacs.bar")
      expect(match[1]).to eq("bar")
    end

    it "should match hello-world.local" do
      match = rewriter.extract_host_from_domain("hello-world.local")
      expect(match).to_not be_nil

      expect(match[0]).to eq("hello-world")
    end

    it "should match lots of dots" do
      match = rewriter.extract_host_from_domain("a.b.c.d.dev")
      expect(match).to_not be_empty

      expect(match[0]).to eq("a.b.c.d")
      expect(match[1]).to eq("d")
    end

    it "should not match foo.local" do
      match = rewriter.extract_host_from_domain("foo.local")
      expect(match).to be_empty
    end

    context 'user sets up a custom top level domain' do
      before(:all) do
        @original_invoker_config = Invoker.config

        Invoker.config = mock
        Invoker.config.stubs(:tld).returns("local")
      end

      it 'should match domain part of incoming request correctly' do
        match = rewriter.extract_host_from_domain("foo.local")
        expect(match).to_not be_empty

        matching_string = match[0]
        expect(matching_string).to eq("foo")
      end

      after(:all) do
        Invoker.config = @original_invoker_config
      end
    end

    context '#select_backend_config' do
      before(:all) do
        @original_invoker_config = Invoker.dns_cache
        @processes = [
          { label: 'foo',     port: 1 },
          { label: 'api.foo', port: 2 },
          { label: 'bar.foo', port: 3 },
        ].map{ |p| OpenStruct.new(p) }
        Invoker.config.stubs(:processes).returns(@processes)
        Invoker.dns_cache = Invoker::DNSCache.new(nil)
      end

      before do
        def rewriter.dns_check(*args)
          socket = StringIO.new
          Invoker::IPC::DnsCheckCommand.new(socket).run_command(Invoker::IPC::Message::DnsCheck.new(*args))
          socket.rewind
          Invoker::IPC.message_from_io socket
        end
      end

      after(:all) do
        Invoker.dns_cache = @original_invoker_config
      end

      it 'matches foo.dev' do
        match = rewriter.select_backend_config('foo.dev')
        expect(match.port).to eql(1)
      end

      it 'matches api.foo.dev' do
        match = rewriter.select_backend_config('api.foo.dev')
        expect(match.port).to eql(2)
      end

      it 'matches bar.foo.dev' do
        match = rewriter.select_backend_config('bar.foo.dev')
        expect(match.port).to eql(3)
      end

      it 'matches baz.foo.dev' do
        match = rewriter.select_backend_config('baz.foo.dev')
        expect(match.port).to eql(1)
      end

      it 'does not match baz.dev' do
        match = rewriter.select_backend_config('baz.dev')
        expect(match.port).to be_nil
      end

      context 'with an alias' do
        it 'matches baz.foo.dev to the alias' do
          @processes[1][:alias] = '*.foo'
          Invoker.dns_cache = Invoker::DNSCache.new(nil)

          match = rewriter.select_backend_config('baz.foo.dev')
          expect(match.port).to eql(2)
        end

        it 'matches baz.dev to the alias' do
          @processes[1][:alias] = '*'
          Invoker.dns_cache = Invoker::DNSCache.new(nil)

          match = rewriter.select_backend_config('baz.dev')
          expect(match.port).to eql(2)
        end

        it 'matches non wildcard alias' do
          @processes[1][:alias] = 'baz'
          Invoker.dns_cache = Invoker::DNSCache.new(nil)

          match = rewriter.select_backend_config('baz.dev')
          expect(match.port).to eql(2)
        end

        it 'does not match baz.foo.blah.dev' do
          @processes[1][:alias] = '*.foo'
          Invoker.dns_cache = Invoker::DNSCache.new(nil)

          match = rewriter.select_backend_config('baz.foo.blah.dev')
          expect(match.port).to be_nil
        end

        it 'matches **' do
          @processes[1][:alias] = '**.foo'
          Invoker.dns_cache = Invoker::DNSCache.new(nil)

          match = rewriter.select_backend_config('a.b.c.foo.dev')
          expect(match.port).to eql(2)
        end
      end
    end
  end
end
