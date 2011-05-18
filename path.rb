require "pp"


class Path
  def initialize(options = {})
    @goal = options[:goal]
    @current_grid = options[:grid]
    @grid_find_closest_hex = options[:find_closest_hex] # method pointer
    @grid_hex_is_blocked = options[:hex_is_blocked] # method pointer
    @step_size = options[:step_size]
    @step_size ||= 10
    @shortest_paths = {}
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
      generate_line_check_points(hex, @goal_hex)
    end
    
    return true if @shortest_paths.size == @current_grid.size
    @shortest_paths
    @grid_find_closest_hex.call()
  end
  def generate_line_check_points(hex, goal)
    moved_goal = [goal[0] - hex[0], goal[1] - hex[1]]
    distance = (moved_goal[0]**2 + moved_goal[1]**2)**(0.5)
    x_ratio = moved_goal[0] / distance
    y_ratio = moved_goal[1] / distance
    steps_needed = distance.to_i / @step_size.to_i
    points_to_check = []
    steps_needed
    1.upto(steps_needed) do |step|
      #px = (x_ratio * distance * (step / steps_needed.to_f)) + hex[0]
      px = (x_ratio * @step_size * step) + hex[0]
      py = (y_ratio * @step_size * step) + hex[1]
      points_to_check << [px, py]
    end
    points_to_check
  end
end


pp Path.new.generate_line_check_points([20,20], [401,401])
