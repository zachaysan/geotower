require "rubygame"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers
class Tower
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  attr_reader :px, :py
  attr_accessor :owner, :name
  def initialize( px, py, image, name, owner )
    @px, @py = px, py
    @normal_state = image
    @image = Surface.load image
    @rect = @image.make_rect
    make_magic_hooks(
      ClockTicked => :update
     )
    @rect.center = [@px,@py]
    @rest = 0
    @cooldown = 2.50
    @fire_time = 1.00
  end
  def update(event)
    dt = event.seconds # time since last update
    aim(dt)
  end
  def aim(dt)
    puts @rest
    @rest -= dt
    return fire_if_target if @rest < 0
    return continue_firing if @rest > @cooldown - @fire_time
    return normal_state
  end
  def normal_state
    update_image @normal_state
  end
  def continue_firing
    # do nothing
  end
  def fire_if_target
    return nil unless scan_for_target
    update_image "images/tower-firing.png"
    @rest = @cooldown
  end
  def scan_for_target
    true
  end
  def update_image(image)
    @image = Surface.load image unless image.nil?
  end
end
