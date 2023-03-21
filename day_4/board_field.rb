class BoardField
  attr_accessor :x, :y, :value, :marked

  def initialize(x:, y:, value:, marked: false)
    @x = x
    @y = y
    @value = value
    @marked = marked
  end

  def mark!
    @marked = true
  end
end
