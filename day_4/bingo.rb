require './bingo_reader'
require './board'

class Bingo
  attr_accessor :drawn_numbers, :raw_boards, :boards

  def initialize(file_path)
    @bingo_reader = BingoReader.new(path: file_path)
    @drawn_numbers = @bingo_reader.drawn_numbers
    @raw_boards = @bingo_reader.parsed_boards
    @boards = []

    create_boards
  end

  def play_with_squid # 🦑
    winner_board, number = catch(:board_with_number) do
      drawn_numbers.each_with_index do |number, index|
        boards.each do |board|
          board.mark_number(number: number)
          throw :board_with_number, [board, number] if index >= 4 && board.bingo?
        end
      end
    end
    winner_board.calculate_score(just_called_number: number.to_i)
  end

  def let_the_squid_win
    board_with_number = []
    drawn_numbers.each_with_index do |number, index|
      boards.each do |board|
        next if board.bingo?

        board.mark_number(number: number)
        board_with_number = [board, number] if index >= 4 && board.bingo?
      end
    end

    last_winner_board, number = board_with_number
    last_winner_board.calculate_score(just_called_number: number.to_i)
  end

  private

  def create_boards
    @raw_boards.each do |board|
      @boards << Board.new(raw_board: board)
    end
  end
end
# require './bingo'
# path = 'bingo_input.txt' #'test_puzzle_input.txt'
# bingo = Bingo.new(path)
# bingo.play_with_squid
