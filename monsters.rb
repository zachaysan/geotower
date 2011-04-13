require "rubygame"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers
class Monsters
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  # where the monstor is on the map
  attr_reader :px, :py
  # the name and information of the monstor
  attr_accessor :owner, :name
  # the acceleration of the creature
  attr_accessor :ax, :ay
  def initialize( px, py, vx, vy, image, name, owner )
    @px, @py = px, py # Current Position
    @vx, @vy = vx, vy # Current Velocity
    
    @ax, @ay = 0, 0 # Current Acceleration
    @name = name
    @max_speed = 600.0 # Max speed on an axis
    @accel = 2000.0 # Max Acceleration on an axis
    @slowdown = 0.0 # Deceleration when not accelerating
 
    @keys = [] # Keys being pressed (might not be useful)
  
    # how the monstor looks
    @image = Surface.load image
    @rect = @image.make_rect
  
    # Create event hooks in the easiest way.
    # These will probably not be needed in *most*
    # monster usecases, but there might be some wierd
    # "take over the monster" powerup
    make_magic_hooks(
       # Send keyboard events to #key_pressed() or #key_released().
      KeyPressed => :key_pressed,
      KeyReleased => :key_released,
       # Send ClockTicked events to #update() this is built into the make_magic_hooks code
      ClockTicked => :update
     )
  end
  def update_image(image)
    @image = Surface.load image unless image.nil?
  end

  private

  # Add it to the list of keys being pressed.
  def key_pressed( event )
    @keys += [event.key]
  end
  # Remove it from the list of keys being pressed.
  def key_released( event )
    @keys -= [event.key]
  end
  # Update the ship state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update
    # do nothing else for now
    update_accel
    update_vel( dt )
    update_pos( dt )
  end
  # Update the acceleration based on what keys are pressed.
  def update_accel
    user_controlling = false
    if user_controlling
      x, y = 0,0
      x -= 1 if @keys.include?( :left )
      x += 1 if @keys.include?( :right )
      y -= 1 if @keys.include?( :up ) # up is down in screen coordinates
      y += 1 if @keys.include?( :down )
      x *= @accel
      y *= @accel
      # Scale to the acceleration rate. This is a bit unrealistic, since
      # it doesn't consider magnitude of x and y combined (diagonal).
      @ax, @ay = x, y
    else
      @ax, @ay = @accel, @accel
    end
  end
  # Update the velocity based on the acceleration and the time since
  # last update.
  def update_vel( dt )
    @vx = update_vel_axis( @vx, @ax, dt )
    @vy = update_vel_axis( @vy, @ay, dt )
  end
  # Calculate the velocity for one axis.
  # v = current velocity on that axis (e.g. @vx)
  # a = current acceleration on that axis (e.g. @ax)
  #
  # Returns what the new velocity (@vx) should be.
  #
  def update_vel_axis( v, a, dt )
    # Apply slowdown if not accelerating.
    if a == 0
      if v > 0
        v -= @slowdown * dt
        v = 0 if v < 0
      elsif v < 0
        v += @slowdown * dt
        v = 0 if v > 0
      end
    end
    # Apply acceleration
    v += a * dt
    # Clamp speed so it doesn't go too fast.
    v = @max_speed if v > @max_speed
    v = -@max_speed if v < -@max_speed
    return v
  end
  # Update the position based on the velocity and the time since last
  # update.
  def update_pos( dt )
    @px += @vx * dt
    @py += @vy * dt
    @rect.center = [@px, @py]
  end
end
