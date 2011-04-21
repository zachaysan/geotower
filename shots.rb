require "rubygame"
require "pp"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers
class Shot
  include Sprites::Sprite
  include EventHandler::HasEventHandler

  attr_reader :px, :py
  attr_accessor :name, :target
  attr_accessor :ax, :ay
  def initialize( px, py, target, name, owner )
    @px, @py = px, py 
    @target = target
    @max_speed = 50.0

    @ax, @ay = 0, 0 # may be needed for missiles that accel
    @name = name

    @accel = 0.0
    @slowdown = 0.0
    
    # how the monstor looks

    @image = Surface.load "images/shot.png"
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
    update_targeted_vel
  end
  def update_targeted_vel
    # similar_triangles  
    sign_x, sign_y = 1,1
    sign_x = -1 if @target[0] > 0
    sign_y = -1 if @target[1] > 0
    ratio_x = @px - @target[0]
    ratio_y = @py - @target[1]
    ratio_h = (ratio_x**2 + ratio_y**2)**0.5
    @vx = @max_speed * (ratio_x / ratio_h) * sign_x
    @vy = @max_speed * (ratio_y / ratio_h) * sign_y

  end

  def update_view
    # @view = Surface.draw_circle_s([@px,@py], 3, :red)
  end

  # Update the shot's state. Called once per frame.
  def update( event )
    dt = event.seconds # Time since last update
    # do nothing else for now
    update_targeted_vel
    update_accel
    update_vel( dt )
    update_pos( dt )
  end
  # Update the acceleration based on what keys are pressed.
  def update_accel
    @ax, @ay = @accel, @accel
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
