require "spec_helper"

describe "PortFinder" do
  before do
    @port_finder = Invoker::Power::PortFinder.new()
    @port_finder.find_ports
  end

  it "should find a http port" do
    expect(@port_finder.http_port).not_to be_nil
  end

  it "should find a dns port" do
    expect(@port_finder.dns_port).not_to be_nil
  end
end
