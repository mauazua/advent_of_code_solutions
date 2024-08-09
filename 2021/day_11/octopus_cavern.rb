require 'pry'
require 'pry-nav'

class InputParser
	attr_reader :input

	def initialize(filepath:)
		@input = File.open(filepath).read.split("\n")
	end

	def call
		prepared_input = []

		@input.each_with_index do |row, x|
			octopuses = row.split('')

			octopuses.each_with_index do |energy, y|
				prepared_input << {x: x, y: y, energy: energy}
			end
		end

		prepared_input
	end
end

class Cavern
	attr_reader :mapped_octopuses, :file_input, :octopuses, :flash_count, :first_common_step

	def initialize(file_input: [])
		@first_common_step = nil
		@octopuses = map_octopuses(file_input: file_input)
		@mapped_octopuses = {}
		@flash_count = 0
		map_octopus_placement
	end

	def find_first_common_step
		temporary_step = 0
		loop do
			break if first_common_step != nil
			process_cavern
			temporary_step += 1
			# binding.pry if flash_count == 3961
			@first_common_step = temporary_step if everyone_together? && @first_common_step == nil
		end
	end

	def process_cavern(steps: 1)
		steps.downto(1) do |step|

			# puts "step: #{step}"
			# puts "#{print_cavern_state}"
			flash_wave!
			octopuses.select {|o| o.just_flashed }.map {|o| o.reset_flash! }
		end
		puts "#{print_cavern_state}"
		puts @flash_count
	end

	def everyone_together?
		octopuses.all? { |o| o.energy == 0 }
	end

	def flash_wave!
		initial_queue = octopuses.select { |octopus| octopus.energy == 9 }

		shine_octopuses(queue: initial_queue)
		octopuses.map(&:accumulate_energy)
	end

	def shine_octopuses(queue:)
		return if queue.empty?
		octopus_to_shine = queue.shift
		octopus_shines!(octopus: octopus_to_shine)
		queue += accumulated_octopuses(octopus: octopus_to_shine)

		shine_octopuses(queue: queue.uniq)
	end

	def octopus_shines!(octopus:)
		octopus.flash!
		@flash_count += 1
		neighbors_of(octopus: octopus).map(&:accumulate_energy)
	end

	def accumulated_octopuses(octopus:)
		neighbors_of(octopus: octopus).select { |o| o.energy == 9 && o.just_flashed == false }
	end

	def map_octopus_placement
		@octopuses.each do |octopus|
			@mapped_octopuses[octopus.key] = octopus
		end
	end

	def neighbors_of(octopus:)
		return nil if octopus.nil?

		candidate_keys = [
			"x#{octopus.x + 1}-y#{octopus.y}",
			"x#{octopus.x - 1}-y#{octopus.y}",
			"x#{octopus.x}-y#{octopus.y + 1}",
			"x#{octopus.x}-y#{octopus.y - 1}",
			"x#{octopus.x + 1}-y#{octopus.y + 1}",
			"x#{octopus.x - 1}-y#{octopus.y - 1}",
			"x#{octopus.x + 1}-y#{octopus.y - 1}",
			"x#{octopus.x - 1}-y#{octopus.y + 1}",
		]

		candidate_keys.map { |key| @mapped_octopuses[key] }.compact
	end

	def map_octopuses(file_input:)
		file_input.map do |attrs|
			Octopus.new(**attrs)
		end
	end

	def print_cavern_state
		groups = octopuses.group_by(&:x)
    groups.each do |x, group|
      energies = group.map { |o| o.energy }
      puts energies.join(' ')
    end; nil
  end
end

class Octopus

	attr_reader :x, :y, :energy, :just_flashed

	def initialize(x:, y:, energy:)
		@x = x
		@y = y
		@energy = energy.to_i
		@just_flashed = false
	end

	def key
		"x#{@x}-y#{@y}"
	end

	def flash!
		return unless energy == 9

		@just_flashed = true
		@energy = 0
  end

  def reset_flash!
  	@just_flashed = false
  end

  def accumulate_energy
  	return if just_flashed || energy == 9
  	@energy += 1
  end
end


