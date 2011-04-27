# Originally imported from the MacRuby sources

class TestToPlist < MiniTest::Unit::TestCase
  include HotCocoa

  def test_normal_cases_in_xml
    @format = :xml
    normal_cases
    @format = nil
    normal_cases
  end

  def test_normal_cases_in_binary
    @format = :binary
    normal_cases
  end

  def normal_cases
    assert_plist 123
    assert_plist true
    assert_plist false
    assert_plist 'foo'
    assert_plist 'aiueo'.transform('latin-hiragana')
    assert_plist :foo, 'foo'
    assert_plist [1,2,3]
    assert_plist 'un' => 1, 'deux' => 2
  end

  def test_raises_error_for_invalid_objects
    assert_raises Exception do nil.to_plist end
    assert_raises Exception do Object.new.to_plist end
    assert_raises Exception do /foo/.to_plist end
    assert_raises Exception do nil.to_plist(:binary) end
  end


  private

  def assert_plist val, expected = val
    ret = @format ? load_plist(val.to_plist(@format)) : load_plist(val.to_plist)
    assert_equal expected, ret
  end

end
