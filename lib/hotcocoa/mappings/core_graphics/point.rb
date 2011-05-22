class CGPoint
  ##
  # (see #carbonize)
  #
  # This is done in-place, but will return nil if the point is not on a screen.
  def carbonize!
    NSScreen.screens.each do |screen|
      if NSPointInRect(self, screen.frame)
        self.y = screen.frame.size.height - self.y + (2 * screen.frame.origin.y)
        return self
      end
    end
    nil
  end

  ##
  # Assumes the point represents a point on a screen that treats the
  # bottom left of the primary screen as the origin (Cocoa co-ordinates),
  # and then translates the point to be in the same place on the screen
  # if treating the top left of the primary screen as the origin (Carbon
  # co-ordinates).
  #
  # @return [CGPoint,nil]
  def carbonize
    point = self.dup
    point.carbonize!
    point
  end
end
