$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require "rubygame"
require "monsters.rb"
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
  end
  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  private
 
  def make_clock
    @clock = Clock.new()
    @clock.target_framerate = 50
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
    @screen = Screen.open( [700, 700], 0, flags )
    @screen.title = "Rocketr in Space!"
  end
  # Quit the game
  def quit
    puts "Quitting!"
    throw :quit
  end
  def step
    @background = Surface.load "images/background.png"
    @background.blit @screen, [ 0, 0]

    # Fetch input events, etc. from SDL, and add them to the queue.
    @queue.fetch_sdl_events
 
    # Tick the clock and add the TickEvent to the queue.
    @queue << @clock.tick
 
    # Process all the events on the queue.
    @queue.each do |event|
      handle( event )
    end
    
    # Draw the ship in its new position.
    @monsters.each {|monster| monster.draw(@screen)} unless @monsters.nil?
    # Refresh the screen.

    @screen.update()
  end
 
end
 
 
# Start the main game loop. It will repeat forever
# until the user quits the game!
Game.new.go
 
 
# Make sure everything is cleaned up properly.
Rubygame.quit()
