class TestCGPointCarbonize < MiniTest::Unit::TestCase
  SCREENS     = NSScreen.screens
  MAIN_SCREEN = NSScreen.mainScreen

  def test_nil_if_coordinate_is_not_on_any_screen
    frames    = SCREENS.map(&:frame)
    max_x     = frames.map(&:origin).map(&:x)    .max
    max_width = frames.map(&:size)  .map(&:width).max
    assert_nil CGPoint.new(max_x + max_width + 1, 0).carbonize!
  end

  def test_origin_in_cocoa_is_bottom_left_in_carbon
    point = CGPointZero.dup.carbonize!
    assert_equal MAIN_SCREEN.frame.size.height, point.y
  end

  def test_middle_of_screen_is_still_middle_of_screen
    frame = MAIN_SCREEN.frame
    point = frame.origin
    point.x = frame.size.width / 2
    point.y = frame.size.height / 2
    assert_equal point, point.dup.carbonize!
  end

  def test_origin_on_secondary_screen_is_bottom_left_of_secondary_screen
    skip 'You need multiple monitors for this test' if SCREENS.count < 2
    SCREENS.each do |screen|
      frame = screen.frame
      point = frame.origin.dup.carbonize!
      assert_equal (frame.size.height + frame.origin.y), point.y, screen.frame.inspect
    end
  end

  def test_middle_of_secondary_screen_is_still_middle_of_secondary_screen
    skip 'You need multiple monitors for this test' if SCREENS.count < 2
    SCREENS.each do |screen|
      frame = screen.frame
      point = frame.origin
      point.x = (frame.size.width / 2)  + point.x
      point.y = (frame.size.height / 2) + point.y
      assert_equal point, point.dup.carbonize!
    end
  end

  def test_does_not_mutate_original
    original_point = CGPointMake(100,100)
    dup_point      = original_point.dup
    new_point      = original_point.carbonize
    refute_equal dup_point, new_point
  end

  def test_aliases
    assert_respond_to CGPointZero, :carbonize!
    assert_respond_to CGPointZero, :carbonize
  end
end
