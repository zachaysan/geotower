require "pp"


class Path

  attr_accessor :goal, :grid_changed
  def initialize(options = {})
    @goal = options[:goal]
    @current_grid = options[:grid]
    @grid_find_closest_hex = options[:find_closest_hex] # method pointer
    @grid_hex_is_blocked = options[:hex_is_blocked] # method pointer
    @step_size = options[:step_size]
    @step_size ||= 10
    @shortest_paths = {}
    @distance_to = {}
    #    find_last_hex
  end
  def find_last_hex
    @goal_hex = @grid_find_closest_hex.call(@goal[0], @goal[1])
    @shortest_paths[@goal_hex] = true
  end
  def find_hex_routes 
    @grid_find_closes_hex.call(@goal_hex[0], @goal_hex[1], (1..-1)).each do |hex|
      if @grid_hex_is_blocked.call( hex )
        @shortest_paths[hex] = false
        next
      end
      any_blocked = Proc.new do |point|
        @grid_hex_is_blocked.call(@grid_find_closes_hex.call(point))
      end
      unless generate_line_check_points(hex, @goal_hex).select(&any_blocked).any?
        @shortest_paths = distance_ratio(hex, @goal_hex)
      end
    end
    
    return true if @shortest_paths.size == @currlent_grid.size
    @shortest_paths
    @grid_find_closest_hex.call() # was here
  end
  def generate_line_check_points(hex, goal)
    x_ratio, y_ratio = distance_ratio(hex, goal)
    steps_needed = distance(hex, goal).to_i / @step_size.to_i
    points_to_check = []
    steps_needed
    1.upto(steps_needed) do |step|
      px = (x_ratio * @step_size * step) + hex[0]
      py = (y_ratio * @step_size * step) + hex[1]
      points_to_check << [px, py]
    end
    points_to_check
  end
  def repath
    
  end
  def distance_ratio(hex, goal)
    moved_goal = [goal[0] - hex[0], goal[1] - hex[1]]
    x_ratio = moved_goal[0] / distance(hex, goal)
    y_ratio = moved_goal[1] / distance(hex, goal)
    return [x_ratio, y_ratio]
  end
  def distance(hex, goal)
    # I tested different ways of doing this. This looks like the fastest: 25% faster than 
    # no memoziation and 45% faster than caching with the array itself. Not sure if it is 
    # worth the RAM trade off yet, but we shall see.
    key = [hex, goal].to_s.to_sym
    return @distance_to[key] unless @distance_to[key].nil? # sorta hack. must research
    moved_goal = [goal[0] - hex[0], goal[1] - hex[1]]
    @distance_to[key] = (moved_goal[0]**2 + moved_goal[1]**2)**(0.5)
  end
end

p = Path.new
pp p.generate_line_check_points([20,20], [401,401])

