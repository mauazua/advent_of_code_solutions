require "minitest/autorun"
require "minitest/pride"
require 'pry'

require_relative 'octopus_cavern'

class TestOctopus < Minitest::Test
  def setup
    @octopus = Octopus.new(x: 1, y: 2, energy: 9)
  end

  def test_key
    assert_equal 'x1-y2', @octopus.key
  end

  def test_flashed
    assert_equal false, @octopus.just_flashed
  end

  def test_flash!
    @octopus.flash!
    assert_equal true, @octopus.just_flashed
    assert_equal 0, @octopus.energy
  end

  def test_accumulate_energy
    octopus = Octopus.new(x: 1, y: 2, energy: 8)
    octopus.accumulate_energy

    assert_equal 9, octopus.energy
  end

  def test_flashed_doesn_accumulate
    octopus = Octopus.new(x: 1, y: 2, energy: 8)
    octopus.instance_variable_set(:@just_flashed, true)
    octopus.accumulate_energy

    assert_equal 8, octopus.energy
  end

  def test_fully_accumulated_does_not_take_more
    octopus = Octopus.new(x: 1, y: 2, energy: 9)
    octopus.accumulate_energy

    assert_equal 9, octopus.energy
  end
end

class TestCavern < Minitest::Test
  def setup
    input_file = 'test_input.txt'
    the_input = 'input.txt'
    @the_input = InputParser.new(filepath: the_input).call
    parsed_input = InputParser.new(filepath: input_file).call
    @cavern = Cavern.new(file_input: parsed_input)
  end

  def test_neighbors_of
    octopus = @cavern.mapped_octopuses['x0-y0']

    neighbors = @cavern.neighbors_of(octopus: octopus).map(&:key)

    assert_equal neighbors, ["x1-y0", "x0-y1", "x1-y1"]
  end

  def test_octopus_shines!
    lit_octopus = @cavern.mapped_octopuses['x1-y1']
    not_lit_octopus = @cavern.mapped_octopuses['x0-y0']
    @cavern.octopus_shines!(octopus: lit_octopus)

    assert_equal 0, lit_octopus.energy
    assert_equal true, lit_octopus.just_flashed

    assert_equal 2, not_lit_octopus.energy
    assert_equal false, not_lit_octopus.just_flashed
  end

  def test_flash_wave!
    lit_octopus = @cavern.mapped_octopuses['x1-y1']
    not_lit_octopus = @cavern.mapped_octopuses['x0-y0']
    octopus_energy_five = @cavern.mapped_octopuses['x4-y2']


    @cavern.flash_wave!

    assert_equal 0, lit_octopus.energy
    assert_equal true, lit_octopus.just_flashed

    assert_equal 3, not_lit_octopus.energy
    assert_equal false, not_lit_octopus.just_flashed

    assert_equal 5, octopus_energy_five.energy
  end

  def test_shine_octopuses
    initial_queue = @cavern.octopuses.select { |octopus| octopus.energy == 9 }

    lit_octopus = @cavern.mapped_octopuses['x1-y1']
    not_lit_octopus = @cavern.mapped_octopuses['x0-y0']
    octopus_energy_four = @cavern.mapped_octopuses['x4-y2']

    @cavern.shine_octopuses(queue: initial_queue)

    assert_equal 0, lit_octopus.energy
    assert_equal true, lit_octopus.just_flashed

    assert_equal 2, not_lit_octopus.energy
    assert_equal false, not_lit_octopus.just_flashed

    assert_equal 4, octopus_energy_four.energy
  end

  def test_process_cavern
    lit_octopus = @cavern.mapped_octopuses['x1-y1']
    not_lit_octopus = @cavern.mapped_octopuses['x0-y0']
    octopus_energy_five = @cavern.mapped_octopuses['x4-y2']

    @cavern.process_cavern

    assert_equal 0, lit_octopus.energy
    assert_equal false, lit_octopus.just_flashed

    assert_equal 3, not_lit_octopus.energy
    assert_equal false, not_lit_octopus.just_flashed

    assert_equal 5, octopus_energy_five.energy
  end

  def test_process_cavern_two_steps
    lit_octopus = @cavern.mapped_octopuses['x1-y1']
    not_lit_octopus = @cavern.mapped_octopuses['x0-y0']
    octopus_energy_six = @cavern.mapped_octopuses['x4-y2']

    @cavern.process_cavern(steps: 2)

    assert_equal 1, lit_octopus.energy
    assert_equal false, lit_octopus.just_flashed

    assert_equal 4, not_lit_octopus.energy
    assert_equal false, not_lit_octopus.just_flashed

    assert_equal 6, octopus_energy_six.energy
  end


  # describe 'example cavern after 1 step' do
  #   before do
  #     puzzle_input = 'example_input.txt'
  #     input = InputParser.new(filepath: puzzle_input).call
  #     @cavern = Cavern.new(file_input: input)
  #     @cavern.process_cavern
  #   end

  #   it 'has 204 octopus flashes in total' do
  #     skip
  #     @cavern.flash_count
  #     _(@cavern.flash_count).must_equal 204
  #   end

  #   it 'first octopus has 6 energy' do
  #     octopus = @cavern.mapped_octopuses['x0-y0']
  #     _(octopus.energy).must_equal 6
  #   end

  #   it 'octopus in last row has 6 energy' do
  #     octopus = @cavern.mapped_octopuses['x9-y0']
  #     _(octopus.energy).must_equal 6
  #   end

  #   it 'octopus in the middle row has 6 energy' do
  #     octopus = @cavern.mapped_octopuses['x4-y6']
  #     _(octopus.energy).must_equal 6
  #   end
  # end

  # describe 'example cavern after 10 steps' do
  #   before do
  #     puzzle_input = 'example_input.txt'
  #     input = InputParser.new(filepath: puzzle_input).call
  #     @cavern = Cavern.new(file_input: input)
  #     @cavern.process_cavern(steps: 10)
  #   end

  #   it 'has 204 octopus flashes in total' do
  #     @cavern.flash_count
  #     _(@cavern.flash_count).must_equal 204
  #   end

  #   it 'first octopus has 0 energy' do
  #     octopus = @cavern.mapped_octopuses['x0-y0']
  #     _(octopus.energy).must_equal 0
  #   end

  #   it 'octopus in last row has 6 energy' do
  #     octopus = @cavern.mapped_octopuses['x9-y0']
  #     _(octopus.energy).must_equal 0
  #   end

  #   it 'octopus in the middle row has 9 energy' do
  #     octopus = @cavern.mapped_octopuses['x4-y6']
  #     _(octopus.energy).must_equal 1
  #   end
  # end

  # describe 'example cavern after 100 steps' do
  #   before do
  #     puzzle_input = 'example_input.txt'
  #     input = InputParser.new(filepath: puzzle_input).call
  #     @cavern = Cavern.new(file_input: input)
  #     @cavern.process_cavern(steps: 100)
  #   end

  #   it 'has 204 octopus flashes in total' do
  #     @cavern.flash_count
  #     _(@cavern.flash_count).must_equal 1656
  #   end

  #   it 'first octopus has 0 energy' do
  #     octopus = @cavern.mapped_octopuses['x0-y0']
  #     _(octopus.energy).must_equal 0
  #   end

  #   it 'octopus in last row has 6 energy' do
  #     octopus = @cavern.mapped_octopuses['x9-y0']
  #     _(octopus.energy).must_equal 6
  #   end

  #   it 'octopus in the middle row has 9 energy' do
  #     octopus = @cavern.mapped_octopuses['x4-y6']
  #     _(octopus.energy).must_equal 9
  #   end
  # end

  def test_actual_run
    big_cavern = Cavern.new(file_input: @the_input)
    big_cavern.process_cavern(steps: 100)
    puts "cavern result: #{big_cavern.flash_count}"
  end

  def test_find_first_common_step
    big_cavern = Cavern.new(file_input: @the_input)
    big_cavern.find_first_common_step
    binding.pry
    refute_equal nil, big_cavern.first_common_step
  end

  describe 'example cavern after 100 steps' do
    before do
      puzzle_input = 'example_input.txt'
      input = InputParser.new(filepath: puzzle_input).call
      @cavern = Cavern.new(file_input: input)
      @cavern.process_cavern(steps: 100)
      _(@cavern.flash_count).must_equal 1656

    end

    it 'octopus in the middle row has 9 energy' do
      octopus = @cavern.mapped_octopuses['x4-y6']
      _(octopus.energy).must_equal 9
    end
  end
end

