require "test_helper"

class TestCommander < Minitest::Unit::TestCase
  def setup
    @commander = Necro::Commander.new()
  end

  def test_start_manaer
    @commander.start_manager()
  end
  
end



