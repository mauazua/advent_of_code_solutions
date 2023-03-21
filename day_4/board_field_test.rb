require 'minitest/autorun'
require_relative 'board_field'

class BoardFieldTest < Minitest::Test

  def test_mark_as_marked
    field = BoardField.new(x: 1, y: 2, value: 22, marked: false)
    field.mark!
    assert_equal true, field.marked
  end
end
