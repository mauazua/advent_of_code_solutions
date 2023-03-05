require './bingo_field'

class Board
  attr_accessor :raw_board, :fields

  def initialize(raw_board:)
    @raw_board = raw_board
    @fields = []
    parse_fields
  end

  private

  def parse_fields
    raw_board.each_with_index do |row, row_index|
      row.split(' ').each_with_index do |value, column_index|
        @fields << BingoField.new(x: row_index, y: column_index, value: value)
      end
    end
  end
end
