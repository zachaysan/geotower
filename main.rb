$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require "rubygame"
require "monsters.rb"
require "towers.rb"
require "shots.rb"
require "grid.rb"
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
    make_towers
    make_monsters
    make_shots
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

  def make_towers
    @towers = []
    @towers << Tower.new(200,200,"images/tower.png",:testing_tower,:me)
    @towers << Tower.new(200,400,"images/tower.png",:testing_tower,:me)
    @towers << Tower.new(300,300,"images/tower.png",:testing_tower,:me)
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
 
    # Don't care about mouse movement just yet (dev mode), so let's ignore it.
    @queue.ignore = [MouseMoved]
  end
  # Create the Rubygame window.
  def make_screen
    flags = [HWSURFACE, DOUBLEBUF] # FULLSCREEN will be added later
    @screen = Screen.open( [600, 900], 0, flags )
    @screen.title = "Geotower for great good!"
  end
  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end
  def get_all_monster_coordinates
    collector = []
    @monsters.each_with_index do |monster, index|
      collector << [monster.public_method(:px), monster.public_method(:py), monster.public_method(:name), monster.public_method(:hp), index]
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
      handle( event )
    end
    
    # Draw the ship in its new position.
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
