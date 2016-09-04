require 'spec_helper'

describe Invoker::Power::UrlRewriter do
  let(:rewriter) { Invoker::Power::UrlRewriter.new }

  before(:all) do
    @original_invoker_config = Invoker.config

    Invoker.config = mock
    Invoker.config.stubs(:tld).returns("dev")
  end

  after(:all) do
    Invoker.config = @original_invoker_config
  end

  def dns_check_result(process_name, port)
    OpenStruct.new(ip: "0.0.0.0", port: port, process_name: process_name)
  end

  describe "#select_backend_config" do
    context "match exists in the config" do
      it "should return it" do
        match = dns_check_result("foo", 3000)
        rewriter.expects(:dns_check).with(:process_name => "foo").returns(match)
        expect(rewriter.select_backend_config("foo.dev").port).to eq(3000)
      end
    end

    context "no match in the config" do
      context "no default" do
        it "should return an empty match" do
          match = dns_check_result("foo", nil)
          default = dns_check_result("default", nil)
          rewriter.stubs(:dns_check).with(:process_name => "foo").returns(match)
          rewriter.stubs(:dns_check).with(:process_name => "default").returns(default)
          expect(rewriter.select_backend_config("foo.dev").port).to eq(nil)
        end
      end

      context "with default" do
        it "should return it" do
          match = dns_check_result("foo", nil)
          default = dns_check_result("default", 3000)
          rewriter.stubs(:dns_check).with(:process_name => "foo").returns(match)
          rewriter.stubs(:dns_check).with(:process_name => "default").returns(default)
          expect(rewriter.select_backend_config("foo.dev").port).to eq(3000)
        end
      end
    end
  end

  describe "#extract_host_from_domain" do
    context "matching domain part of incoming request" do

      it "should match foo.dev" do
        match = rewriter.extract_host_from_domain("foo.dev")
        expect(match).to_not be_empty

        matching_string = match[0]
        expect(matching_string).to eq("foo")
      end

      it "should match foo.dev:1080" do
        match = rewriter.extract_host_from_domain("foo.dev:1080")
        expect(match).to_not be_empty

        matching_string = match[0]
        expect(matching_string).to eq("foo")
      end

      it "should match emacs.bar.dev" do
        match = rewriter.extract_host_from_domain("emacs.bar.dev")
        expect(match).to_not be_empty

        expect(match[0]).to eq("emacs.bar")
        expect(match[1]).to eq("bar")
      end

      it "should match hello-world.dev" do
        match = rewriter.extract_host_from_domain("hello-world.dev")
        expect(match).to_not be_nil

        expect(match[0]).to eq("hello-world")
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
    end
  end
end
