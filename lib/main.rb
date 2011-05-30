$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require "rubygame"
require "monsters.rb"
require "towers.rb"
require "shots.rb"
require "grid.rb"
require "hover_tower.rb"
require "path.rb"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

# The Game class helps organize thing. It takes events
# from the queue and handles them, sometimes performing
# its own action (e.g. Escape key = quit), but also
# passing the events to the pandas to handle.
#
class Game
  include EventHandler::HasEventHandler
 
  def initialize()
    make_screen
    make_clock
    make_queue
    make_event_hooks
    make_grid
    make_hover_tower
    make_towers
    make_monsters
    make_shots
    make_path
    make_goal
  end
  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  private
  
  def make_monsters
    @monsters = []
    @monsters.each {|monster| make_magic_hooks_for( monster, { YesTrigger.new() => :handle } )} unless @monsters.empty?
  end
  
  def make_hover_tower
    @hover_tower = HoverTower.new("images/hexagon.png", :bob, :me)
  end
  
  def make_towers
    @towers = []
    @towers.each {|tower| make_magic_hooks_for( tower, { YesTrigger.new() => :handle } )}
  end

  def make_shots
    @shots = []
    @shots.each {|shot| make_magic_hooks_for( shot, { YesTrigger.new() => :handle } )} unless @shots.empty?
  end
  
  def make_clock
    @clock = Clock.new()
    @clock.target_framerate = 80
    @clock.calibrate
    @clock.enable_tick_events
  end
  def make_event_hooks
    hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit
    }
    make_magic_hooks( hooks )
  end
 
  # Create an EventQueue to take events from the keyboard, etc.
  # The events are taken from the queue and passed to objects
  # as part of the main loop.
  def make_queue
    # Create EventQueue with new-style events (added in Rubygame 2.4)
    @queue = EventQueue.new()
    @queue.enable_new_style_events
  end
  # Create the Rubygame window.
  def make_screen
    flags = [HWSURFACE, DOUBLEBUF] # FULLSCREEN will be added later
    @screen = Screen.open( [600, 900], 0, flags )
    @screen.title = "Geotower for great good!"
  end
  def make_grid
    @grid = Grid.new({})
  end
  def make_path
    @path = Path.new({:find_closest_hex => @grid.public_method(:find_closest_hex), 
                       :hex_is_blocked => @grid.public_method(:hex_is_blocked)})
  end
  def make_goal
    end_goal = [200,200]
    hex_goal = @grid.find_closest_hex end_goal[0], end_goal[1]
    @path.goal = hex_goal
  end
  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end
  def get_all_monster_coordinates
    collector = []
    
    # semi-hack. Will need to fix with a hash or something
    @monsters.each_with_index do |monster, index|
      collector << [monster.public_method(:px), 
                    monster.public_method(:py), 
                    monster.public_method(:name), 
                    monster.public_method(:hp), 
                    index, 
                    monster.public_method(:take_damage)]
    end
    collector
  end
  def generate_new_monster
    if rand < 0.02
      @monsters << Monster.new(100 + 190*rand, 0, 0, 50, "images/monster.png", :test_monster, :game)
      make_magic_hooks_for( @monsters[-1], { YesTrigger.new() => :handle } )
    end
  end
  def fire_shots
    @towers.each do |tower|
      if tower.fire_shot
        @shots << Shot.new( tower.px, tower.py, tower.fire_shot, :simple_shot, :me)
        make_magic_hooks_for(  @shots[-1], { YesTrigger.new() => :handle } )
        tower.fire_shot = nil
      end
    end
  end
  def move_hover_tower(px=nil, py=nil, image=nil)
    hex_px, hex_py = @grid.find_closest_hex(px, py)
    @hover_tower.update_image(hex_px, hex_py, image)
  end
  def clear_the_dead
    to_clear = []
    @monsters.each_with_index do |monster, index|
      to_clear << index if monster.hp <= 0
    end
    to_clear.each do |index|
      @monsters.delete_at(index)
      @shots.delete_if {|shot| shot.target[4] == index}
    end
  end
  def handle_release
    if @hover_tower
      build_tower
    end
  end
  def build_tower
    @towers << Tower.new(@hover_tower.px,@hover_tower.py,"images/tower.png",:testing_tower,:me)
    @towers.last.tap {|tower| make_magic_hooks_for( tower, { YesTrigger.new() => :handle } )}
  end
  def repath
    if @path.grid_changed
      @monsters.each do |monster|
        monster.get_new_course
      end
    end
  end
  def step
    
    puts @clock.framerate
    
    generate_new_monster
    
    @background = Surface.load "images/background.png"
    @background.blit @screen, [ 0, 0]
    
    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events
    
    # Tick the clock and add the TickEvent to the queue.
    @queue << @clock.tick
    current_monster_positions = get_all_monster_coordinates
    
    @towers.each do |tower|
      tower.look_for_monsters current_monster_positions
    end
    
    fire_shots
    
    # Process all the events on the queue.
    @queue.each do |event|
      case(event)
      # we move mouse moved to its own event because it is faster
      when Events::MouseMoved
        @mouse_px, @mouse_py = event.pos
      when Events::MouseReleased
        handle_release
      else handle( event )
      end
    end
    
    # Draw the ship in its new position.
    if @mouse_px and @mouse_py
      move_hover_tower(@mouse_px, @mouse_py)
    end
    clear_the_dead
    @hover_tower.draw(@screen) unless @hover_tower.nil?

    @towers.each {|tower| tower.draw(@screen)} unless @towers.nil?
    @monsters.each {|monster| monster.draw(@screen)} unless @monsters.nil?
    @shots.each {|shot| shot.draw(@screen)} unless @shots.nil?
    # Refresh the screen.

    @screen.update()
  end
 
end
 
 
# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go
 
 
# Make sure everything is cleaned up properly.
Rubygame.quit()
