
class Grid
  # Take in self so that we don't have to type Grid.new.method everytime we want to call it
  class << self
    cos_30_degrees = 0.866025404 # precalc'd to save time
    @s = 20 # the side lenght
    @h = @s/2.0 # the verticle measure of the projection of the roof
    @r = @s*cos_30_degrees # the "radius" of the hgon grid
    @b = @s * 2.0 # need to rename these (they represent the measurements of the box 
    @a = @r * 2.0 # around the hexagon. They are useful to calculating things fast
    def snap(px, py)
      return even_snapper(px, py) if snaps_even? py
      odd_snapper(px, py)
    end
    
    private
    def snaps_even?(py)
      if (py / (@w+@h).to_i).even?
        # break out section coordinates
      end
    end
    def even_snapper
      
    end
    def odd_snapper
      
    end
  end
end

Grid.foo
