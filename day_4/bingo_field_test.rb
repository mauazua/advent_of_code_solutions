require 'minitest/autorun'
require_relative 'bingo_field'

class BingoFieldTest < Minitest::Test

  def test_mark_as_drawn
    field = BingoField.new(x: 1, y: 2, value: 22, drawn: false)
    field.mark_as_drawn!
    assert_equal true, field.drawn
  end
end
