# -*- coding: utf-8 -*-
class Hexagon
  attr_reader :height, :width
  def initialize(height)
    @COS_30_DEGREES = 0.866025404
    #   ___     ___
    #  /   \     |
    # 〈    〉  height
    #  \___/    _|_
    # 
    # |width|
    @height = height
    @width = 2 * @height / @COS_30_DEGREES
  end
  def x_distance_to_next_hex
    # X   X   X
    #   X   X
    # X   X
    # | |
    #
    @COS_30_DEGREES * @height
  end
end

class Grid
  # Take in self so that we don't have to type Grid.new.method everytime we want to call it
  attr_reader :grid_points
  def initialize(options)
    @grid_points = []
    default_grid_options = { :x_start_location => 30, 
      :x_end_location => 400, 
      :y_start_location => 20, 
      :y_end_location => 300,
      :hex_height => 25}
    
    @settings = default_grid_options.merge options
    @hex = Hexagon.new(@settings[:hex_height])
    make_grid_points
  end
  def make_grid_points
    even = true
    @settings[:x_start_location].step(@settings[:x_end_location], @hex.x_distance_to_next_hex) do |px_hex|
      adjusted_y = @settings[:y_start_location]
      adjusted_y += (@hex.height * 0.5) unless even
      adjusted_y.step(@settings[:y_end_location], @hex.height) do |py_hex|
        @grid_points << [px_hex, py_hex]
      end
      even = !even
    end
    @grid_points
  end
  def find_closest_hex(px, py)
    closest_hex = Proc.new do |hex1, hex2|
      ((hex1[0]-px)**2 + (hex1[1] - py)**2) <=> ((hex2[0]-px)**2 + (hex2[1] - py)**2)
    end
    @grid_points.sort(&closest_hex).first
  end
end
