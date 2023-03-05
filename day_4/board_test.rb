require 'minitest/autorun'
require_relative 'board'

class BoardTest < Minitest::Test

  def setup
    raw_board = ["22 13 17 11  0", " 8  2 23  4 24", "21  9 14 16  7", " 6 10  3 18  5", " 1 12 20 15 19"]
    @board = Board.new(raw_board: raw_board)
  end

  def test_fields_present
    assert_equal true, @board.fields.any?
  end

  def test_first_field
    field = @board.fields.first

    assert_equal 0, field.x
    assert_equal 0, field.y
    assert_equal '22', field.value
    assert_equal false, field.drawn
  end
end
