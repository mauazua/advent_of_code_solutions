require './board_field'

class Board
  SIZE = 5

  attr_accessor :raw_board, :fields

  def initialize(raw_board:)
    @raw_board = raw_board
    @fields = []
    parse_fields
  end


  def mark_number(number:)
    field = fields.find { |field| field.value == number }
    field&.mark!
  end

  def bingo?
    marked_fields = fields.select { |field| field.marked }
    bingo(by: :x, marked_fields: marked_fields) || bingo(by: :y, marked_fields: marked_fields)
  end

  def calculate_score(just_called_number:)
    unmarked_fields = fields.reject { |field| field.marked }
    unmarked_fields.sum { |field| field.value.to_i } * just_called_number
  end

  private

  def parse_fields
    raw_board.each_with_index do |row, row_index|
      row.split(' ').each_with_index do |value, column_index|
        @fields << BoardField.new(x: row_index, y: column_index, value: value)
      end
    end
  end

  def bingo(by:, marked_fields:)
    marked_fields.group_by { |field| field.send(by) }.any? { |_index, fields| fields.size == SIZE }
  end
end
