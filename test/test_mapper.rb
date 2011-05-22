# Imported from MacRuby sources

class TestMapper < MiniTest::Unit::TestCase

  include HotCocoa::Mappings

  def test_should_have_two_hash_attributes_named_bindings_and_delegate
    assert Mapper.bindings_modules.is_a?(Hash)
    assert Mapper.delegate_modules.is_a?(Hash)
  end

  [ :control_class, :builder_method, :control_module,
    :map_bindings, :map_bindings= ].each do |method|

    define_method "test_should_have_a_#{method}_attribute" do
      assert_respond_to(sample_mapper, method)
    end

  end

  def test_should_set_its_control_class_on_initialization
    assert_equal(sample_mapper(true).control_class, SampleClass)
  end

  def test_convert_from_camelcase_to_underscore
    assert sample_mapper.class.underscore("SampleCamelCasedWord"), 'sample_camel_cased_word'
  end

  def test_include_in_class
    m = sample_mapper(true)
    m.include_in_class

    assert_equal m.instance_variable_get('@extension_method'), :include

    skip 'Pending.'
  end

  def test_custom_methods_override_existing_methods
    service = HotCocoa.bonjour_service type:'_test._tcp.', name:'HotCocoa Test'
    assert_equal -1, service.method(:resolve).arity

    service = NSNetService.alloc.initWithDomain '',
                                           type:'_test._tcp.',
                                           name:'HotCocoa Test'
    assert_equal 0, service.method(:resolve).arity
  end


  private

  def sample_mapper(flush = false)
    @mapper = nil if flush
    @mapper || Mapper.new(SampleClass)
  end

end
