require 'pry'
require 'pry-nav'

class TransparentOrigami
  attr_accessor :points, :dot_points
  OPPOSITE_AXIS = {
    x: :y,
    y: :x
  }
  
  def initialize(path:)
    @parser = InputParser.new(path: path)
    @raw_dot_points = @parser.dot_points if @parser
    @instructions = @parser.instructions if @parser
    @points = []
    @dot_points = []

    populate_points
  end

  def fold
    @instructions.each do |instruction|

      puts "processing instruction: #{instruction}"
      line = instruction.match(/\d{1,4}/).to_s
      axis = instruction.match(/[x,y]/).to_s

      process_single_fold(axis: axis, line: line.to_i)

      count_of_points = @dot_points.size
    end

    populate_empty_points
  end

  def display
    count_of_points = @dot_points.size
    puts "##############################"
    puts "count of points: #{count_of_points}"
    puts "##############################"
    groups = @points.sort.reverse.group_by(&:y)

    groups.each do |y, group|
      values = group.map { |o| o.value }
      puts values.join('')
    end; nil
  end

  private

  def populate_points
    populate_dot_points
  end

  def populate_dot_points
    return if @raw_dot_points.nil?

    @raw_dot_points.each do |data|
      x, y = data.chomp.split(',').map(&:to_i)

      point = DotPoint.new(x: x, y: y)

      @points << point
      @dot_points << point
    end
  end

  def populate_empty_points
    return if @dot_points.empty?

    max_x = @dot_points.max_by(&:x).x
    max_y = @dot_points.max_by(&:y).y
    min_x = @dot_points.min_by(&:x).x
    min_y = @dot_points.min_by(&:y).y

    x_values = (min_x..max_x).to_a
    y_values = (min_y..max_y).to_a


    x_values.each do |x|
      y_values.each do |y|
        temporary_point = Point.new(x: x, y: y)
        next unless @points.find { |point| point == temporary_point }.nil?

        @points << temporary_point
      end
    end
  end

  def process_single_fold(axis:, line:)
    points_to_move = @dot_points.select { |point| point.send(axis.to_s) >= line }

    points_to_move.each do |point|
      new_placement = calculate_new_point_placement(point: point, axis: axis, line: line)
      other_axis = OPPOSITE_AXIS[axis.to_sym]

      temporary_point = Point.new("#{axis}": new_placement, "#{other_axis}": point.send(other_axis))
      point_on_that_place = !@points.find { |ppoint| ppoint == temporary_point }.nil?

      next if point_on_that_place

      point.move_to(axis: axis, new_value: new_placement)
    end

    points_to_drop = points.select { |point| point.send(axis.to_sym) > line }
    @points -= points_to_drop

    @dot_points = @points.select { |point| point.is_a?(DotPoint) }
  end

  def calculate_new_point_placement(point:, axis:, line:)
    current = point.send(axis)

    move_by = ((current - line).abs) * 2
    current - move_by
  end
end

class Point

  attr_accessor :x, :y

  def initialize(x:, y:)
    @x = x
    @y = y
    @value = value
  end

  def value
    ' '
  end

  def move_to(axis:, new_value:)
    instance_variable_set(:"@#{axis}", new_value)
    self
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def <=>(other)
    return nil unless [DotPoint, Point].include? other.class

    return 0 if self == other
    # first we want the points that have the higher y value
    # if y's are equal, we want points with higher x first
    if self.y > other.y
      return -1 # self is smaller
    elsif self.y < other.y
      return 1 # self is bigger
    elsif self.y == other.y && self.x > other.x
      return -1 # self is smaller
    elsif self.y == other.y && self.x < other.x
      return 1 # self is bigger
    else
      -1
    end
  end

end


class DotPoint < Point
  def value
    '#'
  end

end

class InputParser
  attr_accessor :path, :dot_points, :instructions
  
  def initialize(path:)
    @path = path
    read_file
  end

  def read_file
    return if path.empty?
    content = File.open(path).readlines
    @dot_points = content.select { |line| line[/\d{1,4},\d{1,4}/] }
    @instructions = content.select { |line| line[/fold along/] }
  end
end


path = 'input.txt'
require_relative 'transparent_origami.rb'
origami = TransparentOrigami.new(path:path)
origami.fold
origami.display
