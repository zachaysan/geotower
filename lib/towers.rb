require "rubygame"
require "pp"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers
class Tower
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  attr_reader :px, :py
  attr_accessor :owner, :name
  
  attr_accessor :current_monsters_in_range, :current_target, :fire_shot
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
    @cooldown = 0.50
    @fire_time = 0.20
    @range = 50
    @current_target = []
  end
  def update(event)
    dt = event.seconds # time since last update
    aim(dt)
  end
  def look_for_monsters(current_monster_positions)
    @current_monsters_in_range = []
    current_monster_positions.each do |monster_position|
      m_px, m_py, m_name, m_hp, m_index = monster_position
      @current_monsters_in_range << monster_position if in_range?(m_px.call, m_py.call)
    end
  end
  def in_range?(x, y)
    ((x-@px)**2 + (y-@py)**2) < @range**2
  end
  def aim(dt)
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
    @fire_shot = @current_target
    @rest = @cooldown
  end
  def scan_for_target
    if @current_monsters_in_range.nil? or @current_monsters_in_range.empty?
      @current_target = []
      false
    else
      find_good_target
      true
    end

  end
  def find_good_target
    @current_target 
    @current_monsters_in_range.sort! do |x,y|
      x[3].call <=> y[3].call
    end
    @current_target = @current_monsters_in_range[0]
  end
  def update_image(image)
    @image = Surface.load image unless image.nil?
  end
end
