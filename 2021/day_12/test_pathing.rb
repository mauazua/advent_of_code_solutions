require "minitest/autorun"
require "minitest/pride"
require 'pry'

require_relative 'pathing'

class TestPathing < Minitest::Test
  def setup
    @pathing = Pathing.new(input_path: 'test_input.txt')
    # @pathing = Pathing.new(input_path: 'input.txt')
    @looser_pathing = Pathing.new(input_path: 'test_input.txt')
    @pathing.prepare_paths
    @looser_pathing.prepare_paths(check_small_caves_once: false)
    @paths = @pathing.paths
  end

  def test_paths_amount
    assert_equal 10, @paths.length
  end

  def test_map_connection
    assert_equal ["A", "b"], @pathing.connections["start"]
    assert_equal ["b"], @pathing.connections["d"]
    assert_equal ["start", "A", "d", "end"], @pathing.connections["b"]
  end

  def test_includes_all_possible_paths
    assert_includes @paths, ["start","A","b","A","c","A","end"]
    assert_includes @paths, ["start","A","b","A","end"]
    assert_includes @paths, ["start","A","b","end"]
    assert_includes @paths, ["start","A","c","A","b","A","end"]
    assert_includes @paths, ["start","A","c","A","b","end"]
    assert_includes @paths, ["start","A","c","A","end"]
    assert_includes @paths, ["start","b","A","c","A","end"]
    assert_includes @paths, ["start","b","A","end"]
    assert_includes @paths, ["start","b","end"]
  end

  def test_looser_paths_count
    assert_equal 103, @looser_pathing.paths.length
  end
end
