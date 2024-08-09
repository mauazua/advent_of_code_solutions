require 'pry'
require 'pry-nav'

class InputParser
	attr_reader :input
	attr_accessor :lines, :final_score


	def initialize(filepath:)
		@input = File.open(filepath).read.split("\n")
		@lines = []
	end

	def call
		input.each do |syntax|
			line = Line.new(syntax)
			line.parse
			@lines.push(line)
		end
		calculate_score
		select_medium_completion_score
	end

	def calculate_score
		@final_score = ScoreCalculator.new(lines: lines.reject(&:valid)).call
		puts "score: #{@final_score}"
		@final_score
	end

	def select_medium_completion_score
		lines = @lines.select(&:valid)
		completors = lines.map do |line|
			LineCompleter.call(line_to_complete: line)
		end
		completors.map {|comp| comp.calculate_completion_score(calculator: CompletionScoreCalculator) }

		median_index = (completors.length - 1 ) / 2

		completors.sort_by(&:score)[median_index].score
	end
end

class Line
	attr_accessor :stack, :syntax, :valid, :invalid_char

	def initialize(syntax)
		@syntax = syntax
		@stack = []
		@valid = true
		@invalid_char = ''
	end
	
	def parse
		syntax.split('').each do |char|
			character = initialize_character(char)
			break unless @valid

			if character.opening_character?
				add_to_stack(char)
			elsif can_be_closing?(character)
				remove_from_stack(char)
			else
				@valid = false
				@invalid_char = char
				puts "expected #{find_matching_closing_for(stack.last)}, but got #{@invalid_char}"
			end
		end
	end

	def initialize_character(char)
		Character.new(char)
	end

	def can_be_closing?(character)
		return unless character.closing_character?
		stack.last == character.matching_opening
	end

	def find_matching_closing_for(char)
		Character.new(char).matching_closing
	end

	def add_to_stack(character)
		stack.push character
	end

	def remove_from_stack(_character)
		stack.pop
	end
end

class Character
	attr_accessor :char

	OPENING_CHARACTERS = ['(', '[', '{', '<']
	CLOSING_CHARACTERS = [')', ']', '}', '>']
	PAIRS = { '(': ')', '{': '}', '[': ']', '<': '>'}

	def initialize(character)
		@char = character
	end

	def opening_character?(character=nil)
		OPENING_CHARACTERS.include? char
	end

	def closing_character?(character=nil)
		CLOSING_CHARACTERS.include?(char)
	end

	def matching_opening
		PAIRS.key(char).to_s
	end

	def matching_closing
		PAIRS.fetch(char.to_sym)
	end
end

class ScoreCalculator
	attr_accessor :lines, :sum
	SCORE_TABLE = {
		')' => 3,
		']' => 57,
		'}' => 1197,
		'>' => 25137,
	}

	def initialize(lines:)
		@lines = lines
		@sum = 0
	end

	def call
		@lines.map do |line|
			@sum += SCORE_TABLE[line.invalid_char]
		end
		sum
	end
end

class LineCompleter
	attr_accessor :line_to_complete, :completion, :score

	def self.call(line_to_complete:)
		new(line_to_complete: line_to_complete).call
	end

	def initialize(line_to_complete:)
		@line_to_complete = line_to_complete
		@completion = []
	end

	def call
		stack_copy = line_to_complete.stack.reverse
		stack_copy.each do |char|
			completion << Character.new(char).matching_closing
		end

		self
	end

	def calculate_completion_score(calculator:)
		result = calculator.call(completion)
		@score = result
	end
end

class CompletionScoreCalculator
	SCORE_TABLE = {
		')' => 1,
		']' => 2,
		'}' => 3,
		'>' => 4,
	}

	def self.call(completion)
		sum = 0
		completion.each do |char|
			sum *= 5
			sum += SCORE_TABLE[char]
		end

		sum
	end
end

filepath = 'input.txt'
InputParser.new(filepath: filepath).call
