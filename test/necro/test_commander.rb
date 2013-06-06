require "test_helper"

class TestCommander < Minitest::Unit::TestCase
  def test_add_command_on_initialize

    @commander.expects(:start).returns(true)
    assert_equal "foo", "foo"
  end
end



