require './bingo_reader'
require './board'

class Bingo
  attr_accessor :drawn_numbers, :raw_boards, :boards

  def initialize(file_path)
    bingo_reader = BingoReader.new(path: file_path)
    drawn_numbers = bingo_reader.drawn_numbers
    @raw_boards = bingo_reader.parsed_boards
    @boards = []

    create_boards
  end

  private

  def create_boards
    @raw_boards.each do |board|
      @boards << Board.new(raw_board: board)
    end
  end
end
# require './bingo'
# path = 'test_puzzle_input.txt'
# Bingo.new(path)
