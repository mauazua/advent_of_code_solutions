class BingoReader
  attr_accessor :drawn_numbers, :path, :parsed_boards

  def initialize(path:)
    @path = path
    read_file
  end

  private

  def read_file
    content = File.open(path)
    @drawn_numbers = content.gets.chomp.split(',')

    read_boards(content: content)
  end

  def read_boards(content:)
    boards = content.readlines
    @parsed_boards = []
    boards.each_slice(6) do |board|
      @parsed_boards << board.map { |line| line.chomp }[1..-1]
    end
  end
end
