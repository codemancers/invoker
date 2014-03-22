require "spec_helper"

describe MM::ListResponse do
  context "serializing a response" do
    let(:process_array) do
      [
        { shell_command: 'foo', process_name: 'foo', dir: '/tmp', pid: 100 },
        { shell_command: 'bar', process_name: 'bar', dir: '/tmp', pid: 200 }
      ]
    end

    let(:message) { MM::ListResponse.new(processes: process_array) }

    it "should prepare proper json" do
      json_hash = message.as_json
      expect(json_hash[:type]).to eql "list_response"
      expect(json_hash[:processes]).to have(2).elements
      expect(json_hash[:processes][0]).to be_a(Hash)
      expect(json_hash[:processes][1]).to be_a(Hash)
    end
  end
end
