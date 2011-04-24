# Originally imported from MacRuby sources

module TestNamespaceForConstLookup
  def self.const_missing(const)
    @missing_const = const
  end

  def self.missing_const
    @missing_const
  end
end

class TestObjectExt < MiniTest::Unit::TestCase
  def test_returns_a_constant_by_FQ_name__in__receiver_namespace
    assert_equal HotCocoa,           Object.full_const_get('HotCocoa')
    assert_equal HotCocoa::Mappings, Object.full_const_get('HotCocoa::Mappings')
  end

  def test_calls_const_missing_on_the_namespace_which__does__exist
    Object.full_const_get('TestNamespaceForConstLookup::DoesNotExist')
    assert_equal 'DoesNotExist', TestNamespaceForConstLookup.missing_const
  end

  def test_raises_a_NameError_if_a_const_cannot_be_found
    assert_raises NameError do
      Object.full_const_get('DoesNotExist::ForSure')
    end
  end

  def test_ignores_leading_namespace_separator
    assert_equal HotCocoa, Object.full_const_get('::HotCocoa')
    assert_equal HotCocoa::Mappings, Object.full_const_get('::HotCocoa::Mappings')
  end
end
