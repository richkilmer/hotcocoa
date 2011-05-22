# Originally imported from MacRuby sources

class TestMapper < MiniTest::Unit::TestCase
  include HotCocoa::Mappings

  def test_has_two_hash_attributes_named_bindings_and_delegate
    assert_instance_of Hash, Mapper.bindings_modules
    assert_instance_of Hash, Mapper.delegate_modules
  end

  [ :control_class, :builder_method, :control_module,
    :map_bindings, :map_bindings= ].each do |method|

    define_method "test_has_a_#{method}_attribute" do
      assert_respond_to sample_mapper, method
    end

  end

  def test_sets_its_control_class_on_initialization
    assert_equal sample_mapper(true).control_class, SampleClass
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
    HotCocoa::Mappings.map sample: SampleClass do
      def alloc_with_options opts
        SampleClass.new
      end
      custom_methods do
        def some_method
          true
        end
      end
    end
    object = HotCocoa.sample
    assert object.some_method
  end


  private

  def sample_mapper(flush = false)
    @mapper = nil if flush
    @mapper || Mapper.new(SampleClass)
  end

end
