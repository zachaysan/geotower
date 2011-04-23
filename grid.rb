
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

    # this method needs to be refactored
    def snaps_even?(py, px)
      if (py / (@w+@h).to_i).even? # this line might be wrong
        base = (2*r).to_i / px.to_i
        px = px - base
        base = (2*s).to_i / py.to_i
        py = py - base
        ratio = py.to_f / h.to_f
        unless (1 - ratio)*@r < px
          return "top-left-even-triangle"
        end
        if px.to_i / r.to_i > 0
          #might be right triangle
          px = px - r 
          unless (1 - ratio)*@r > px
            return "top-right-even-triangle"
          end
        end
        return "normal even"
      end
      false
    end
    def snaps_odd
      px -= (px.to_i/(2*@r.to_i))*2*@r.to_f
      # since we know it is odd (because the previous method failed to execute)
      # we know we need to subtract out a @h and an @s 
      py -= (@h + @s)
      #now that we've subtracted out the even layer we need to subtract out the whole hgons 
      py -= (py.to_i/(2*@s.to_i))*2*@s.to_f
      
      # note that since the problem is symetrical we can use a coordinate transform
      # solve it once then inverse the new px value and solve it again
      side = :left
      side = :right if px < @r
      if side == :left
        symmetrical_odd_solver(px, py)
      else
        symmetrical_odd_solver(px*-1, py)
      end
    end
    def symmetrical_odd_solver
      return :not_top if py/@h > 0
      ratio = py.to_f/@h.to_f 
      return :top if px < (1 - ratio)*@r
      return :not_top
    end
    def even_snapper
      
    end
    def odd_snapper
      
    end
  end
end

Grid.foo
