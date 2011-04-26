# Originally imported from the MacRuby sources


class TestMappingsTypes < MiniTest::Unit::TestCase
  include HotCocoa

  def test_has_two_Hash_attributes_named_mappings_and_frameworks
    assert Mappings.mappings.is_a?(Hash)
    assert Mappings.frameworks.is_a?(Hash)
  end

end


class TestMappingsMappings < MiniTest::Unit::TestCase
  include HotCocoa

  def teardown
    Mappings.mappings[:klass] = nil
  end

  def test_creates_a_mapping_to_a_class_with_a_Class_instance_given_to_map
    Mappings.map( klass: SampleClass ) { }
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_creates_a_mapping_to_a_class_with_a_String_given_to_map
    Mappings.map( klass: 'SampleClass' ) { }
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_creates_a_mapping_to_a_class_with_a_Symbol_given_to_map
    Mappings.map( klass: :SampleClass ) { }
    assert_equal SampleClass, Mappings.mappings[:klass].control_class
  end

  def test_registers_the_first_key_in_the_options_given_to_map_as_the_builder_method
    Mappings.map( klass: SampleClass ) { }
    assert_equal Mappings.mappings[:klass].builder_method, :klass

    Mappings.map( klass: SampleClass, other_key: 'value' ) {}
    assert_equal Mappings.mappings[:klass].builder_method, :klass
  end

  def test_uses_the_block_given_to_map_as_the_control_module_body
    Mappings.map( klass: SampleClass ) do
      def a_control_module_instance_method; end
    end

    assert Mappings.mappings[:klass].control_module.
            instance_methods.include?(:a_control_module_instance_method)
  end

end


class TestMappingsMap < MiniTest::Unit::TestCase
  include HotCocoa

  # @todo This test needs to be expanded upon
  def test_creates_a_mapping_to_a_class_in_a_framework
    map_block_called = false

    Mappings.map( klass: 'SampleClass', framework: 'OpenCL' ) do
      map_block_called = true
    end
    Mappings.frameworks['OpenCL'].last.call

    assert map_block_called
  end

  def test_reload_loads_all_mappings
    file = File.join(`git rev-parse --show-toplevel`.chomp,
                     'lib/hotcocoa/mappings/test.rb')
    File.open(file,'w') { |f| f.puts 'class MyReloadingTestClass; end' }

    HotCocoa::Mappings.reload
    assert defined?(:MyReloadingTestClass)
  ensure
    FileUtils.rm file
  end

end


class TestFrameworkLazyLoading < MiniTest::Unit::TestCase
  include HotCocoa

  def test_executes_the_frameworks_callbacks_when_framework_loaded_is_called
    mocks = Array.new(2) do
      mock = MiniTest::Mock.new
      mock.expect :call, true, []
      mock
    end

    mocks.each { |mock| Mappings.on_framework('IMCore') do mock.call end }
    framework 'IMCore'

    mocks.each { |mock| assert mock.verify }
  end

  # e.g. To define a movie view you need QTKit loaded, but you will use
  #      the symbols from QTKit during the definition before the
  #      framework is loaded
  def test_resolves_a_constant_from_a_framework_that_has_not_been_loaded
    Mappings.map( cw_config: 'CWConfiguration', framework: 'CoreWLAN' ) { }
    # The mapping should not yet exist, so it will not resolve
    assert_nil Mappings.mappings[:cw_config]
    framework 'CoreWLAN'
    assert_equal CWConfiguration, Mappings.mappings[:cw_config].control_class
  end

  def test_returns_whether_or_not_a_framework_has_been_loaded_yet
    assert Mappings.loaded_framework?('Cocoa')
    refute Mappings.loaded_framework?('IHasNotBeenLoaded')
    refute Mappings.loaded_framework?(nil)
    refute Mappings.loaded_framework?('')
  end

end
