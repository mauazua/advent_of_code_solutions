class Pathing
	attr_accessor :parsed_input, :paths, :connections, :check_small_caves_once

	def initialize(input_path:)
		@paths = []
		@connections = {}
		parse_input(input_path: input_path)
		prepare_paths
	end

	def prepare_paths(check_small_caves_once: true)
		@check_small_caves_once = check_small_caves_once
		map_connections
		check_candidate_steps(current_cave: 'start', candidates: @connections['start'])

		@paths.uniq!
		puts "generated patsh: #{@paths}"
		self
	end

	def parse_input(input_path:)
		@parsed_input = File.open(input_path).read.split("\n")
	end

	def map_connections
		split_input = @parsed_input.map { |entry| entry.split('-') }
		split_input.each do |from_node, to_node|
			make_connection(from_node: from_node, to_node: to_node)
			make_connection(from_node: to_node, to_node: from_node)
		end
	end

	def make_connection(from_node:, to_node:)
		points = @connections[from_node] || []
		points |= [to_node]
		@connections[from_node] = points
	end

	def check_candidate_steps(current_cave:, candidates: [], visited_caves: [], possible_path: [])
		possible_path << current_cave
		visited_caves << current_cave
		return if candidates.empty?

		potential_scan_result = candidates.each do |candie|
			break possible_path if possible_path.last == 'end'

			# next_candidates = @connections[candie].reject { |conn| !!conn.match(/\p{Lower}/) && visited_caves.include?(conn)}
			next_candidates = prepare_candidates(candidates:@connections[candie], visited_caves:visited_caves)
			check_candidate_steps(current_cave: candie, candidates: next_candidates, visited_caves: visited_caves.dup, possible_path: possible_path.dup)
		end

		@paths << potential_scan_result if potential_scan_result.include?('start') && potential_scan_result.include?('end')
	end

	def prepare_candidates(candidates:, visited_caves:)
		if check_small_caves_once
			candidates.reject { |conn| !!conn.match(/\p{Lower}/) && visited_caves.include?(conn)}
		else
			candidates.reject do |conn|
				# binding.pry
				['start', 'end'].include?(conn) || (!!conn.match(/\p{Lower}/) && (visited_caves.tally[conn] || 0) >= 2)
			end
		end

	end
end

