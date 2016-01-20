require 'spec_helper'

describe Invoker::Power::UrlRewriter do
  let(:rewriter) { Invoker::Power::UrlRewriter.new }

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
        Invoker.tld = 'local'
      end

      it 'should match domain part of incoming request correctly' do
        match = rewriter.extract_host_from_domain("foo.local")
        expect(match).to_not be_empty

        matching_string = match[0]
        expect(matching_string).to eq("foo")
      end

      after(:all) do
        Invoker.reset_tld
      end
    end
  end
end
