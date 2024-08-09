require "minitest/autorun"
require 'minitest/pride'
require 'pry'

require_relative 'line_parsing'

class TestCalculator < Minitest::Test
  def setup
    input_file = 'test_input.txt'
    # input_file = 'line.txt'
    @parser = InputParser.new(filepath: input_file)
    @parser.call

  end

  def test_final_score
    assert_equal 26397, @parser.final_score
  end
end

class TestLine < Minitest::Test
  def setup
    @line = Line.new('[({(<(())[]>[[{[]{<()<>>')
    @line.parse
  end

  def test_stack
    assert_equal @line.stack, ["[", "(", "{", "(", "[", "[", "{", "{"]
  end
end

class TestLineCompleter < Minitest::Test
  def setup
    line = Line.new('[({(<(())[]>[[{[]{<()<>>')
    line.parse
    @line_completer = LineCompleter.call(line_to_complete: line)
  end

  def test_proposed_completion
    assert_equal @line_completer.completion, ["}", "}", "]", "]", ")", "}", ")", "]"]
  end
end

class TestCompletionScoreCalculator < Minitest::Test
  def setup
    line = Line.new('[({(<(())[]>[[{[]{<()<>>')
    line.parse
    @line_completer = LineCompleter.call(line_to_complete: line)
    calculator = CompletionScoreCalculator
    @line_completer.calculate_completion_score(calculator: calculator)
  end

  def test_completion_score
    assert_equal @line_completer.score, 288957
  end
end

class TestInputParser < Minitest::Test
  def setup
    input_file = 'test_input.txt'
    # input_file = 'line.txt'
    @parser = InputParser.new(filepath: input_file)
    @parser.call
  end

  def test_select_medium_completion_score
    assert_equal @parser.select_medium_completion_score, 288957
  end
end

