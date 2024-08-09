require 'minitest/autorun'
require_relative 'transparent_origami'

class TransparentOrigamiTest < Minitest::Test
  def test_new_origami
    origami = TransparentOrigami.new(path: 'test_input.txt')
    point_coordinates = origami.dot_points.map {|point| [point.x, point.y] }

    assert_includes point_coordinates, [1,1]
    assert_includes point_coordinates, [5,4]
    assert_includes point_coordinates, [9,9]
  end

  def test_fold
    origami = TransparentOrigami.new(path: 'test_input.txt')

    origami.fold

    point_coordinates = origami.dot_points.sort.map {|point| [point.x, point.y] }
    # First come points with higher y's; within them, we sort x's in ascending order
    assert_equal point_coordinates, [[2, 2], [1, 2], [3, 1], [2, 1], [1, 1], [1, 0], [1, -1]]
  end
end

class PointTest < Minitest::Test

  def test_value
    point = Point.new(x:1, y:1)
    assert_equal ' ', point.value
  end

  def test_move_to
    point = Point.new(x:9, y:9)
    point.move_to(axis: 'x', new_value: 5)

    assert_equal 5, point.x
  end

  def test_comparison_points_not_equal
    point = Point.new(x:9, y:9)
    other = Point.new(x:9, y:8)

    refute point == other
  end

  def test_comparison_points_equal
    point = Point.new(x:9, y:9)
    other = Point.new(x:9, y:9)

    assert point == other
  end

  def test_comparison_point_dot_point_not_equal
    point = DotPoint.new(x:9, y:9)
    other = Point.new(x:9, y:8)

    refute point == other
  end

  def test_comparison_point_dot_point_equal
    point = DotPoint.new(x:9, y:9)
    other = Point.new(x:9, y:9)

    assert point == other
  end

  def test_spaceship_point_bigger_than_other_point
    # point's y is 3 and other's y is 1; point(self) is "smaller" (should come first in sorting)
    point = Point.new(x:1, y:3)
    other = Point.new(x:2, y:1)

    assert_equal -1, point <=> other
  end

  def test_spaceship_point_smaller_than_other_point
    # point's y is 1 and other's y is 2; point(self) is "bigger" (should come later in sorting)
    point = Point.new(x:1, y:1)
    other = Point.new(x:2, y:2)

    assert_equal 1, point <=> other
  end

  def test_spaceship_point_bigger_than_other_point
    # y's are equal; point's x is 1 and other's x is 2; point(self) is "bigger"
    point = Point.new(x:1, y:2)
    other = Point.new(x:2, y:2)

    assert_equal 1, point <=> other
  end

  def test_spaceship_point_equal_to_other_point
    # y's are equal; point's x are equal; points have the same coords.
    point = Point.new(x:2, y:2)
    other = DotPoint.new(x:2, y:2)

    assert_equal 0, point <=> other
  end

  def test_spaceship_point_smaller_than_dot_point
    # point's y is 1 and other's y is 2; point(self) is "bigger" (should come later in sorting)
    point = Point.new(x:2, y:1)
    other = DotPoint.new(x:2, y:2)

    assert_equal 1, point <=> other
  end

  def test_spaceship_incomparable
    point = Point.new(x:2, y:1)
    other = 'DotPoint'

    assert_equal nil, point <=> other
  end

  def test_sorting_points
    origami = TransparentOrigami.new(path: 'test_input.txt')

    sorted_points = origami.dot_points.sort
    coords = sorted_points.map {|point| [point.x, point.y] }

    assert_equal [[9, 9], [5, 4], [1, 3], [2, 2], [1, 2], [3, 1], [2, 1], [1, 1]], coords
  end

end

class DotPointTest < Minitest::Test

  def test_value
    point = DotPoint.new(x:1, y:1)
    assert_equal '#', point.value
  end
end
