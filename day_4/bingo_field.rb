class BingoField
  attr_accessor :x, :y, :value, :drawn

  def initialize(x:, y:, value:, drawn: false)
    @x = x
    @y = y
    @value = value
    @drawn = drawn
  end

  def mark_as_drawn!
    @drawn = true
  end
end
