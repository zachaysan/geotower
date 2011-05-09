require "rubygame"
include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers
class HoverTower
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  attr_accessor :px, :py
  attr_accessor :owner, :name
  def initialize(image, name, owner )
    @image_path = image
    @name = name
    @owner = owner
    @image = Surface.load @image_path
    @rect = @image.make_rect
    
    make_magic_hooks( ClockTicked => :update  )
  end
  def normal_state
    update_image @normal_state
  end
  def find_good_target
    @current_target 
    @current_monsters_in_range.sort! do |x,y|
      x[3].call <=> y[3].call
    end
    @current_target = @current_monsters_in_range[0]
  end
  def update_image(px,py,image=nil)
    @px, @py = px, py
    unless image.nil?
      @image = Surface.load image
      @rect = @image.make_rect
    end
    @rect.center = [@px,@py]
  end
end
