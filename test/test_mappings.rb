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


class TestMap < MiniTest::Unit::TestCase

  include HotCocoa

  def test_should_create_a_mapping_to_a_class_in_a_framework_with_map
    map_block_called = false

    Mappings.map(:klass => 'SampleClass', :framework => 'TheFramework') do
      map_block_called = true
    end
    Mappings.frameworks["theframework"].last.call

    assert map_block_called
  end

  def test_reload
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

  def teardown
    Mappings.frameworks['theframework'] = nil
    Mappings.loaded_frameworks.delete('theframework')
  end

  def test_should_execute_the_frameworks_callbacks_when_framework_loaded_is_called
    mocks = Array.new(2) do
      mock = MiniTest::Mock.new
      mock.expect :call, true, []
      mock
    end

    mocks.each { |mock| Mappings.on_framework('TheFramework') do mock.call end }
    Mappings.framework_loaded('TheFramework')

    mocks.each { |mock| assert mock.verify }
  end

  def test_should_do_nothing_if_the_framework_loaded_is_not_registered
    Mappings.framework_loaded('FrameworkDoesNotExist')
    assert true # hack, we want to test that nothing is raised by the above call
  end

  def test_should_resolve_a_constant_when_a_framework_thats_registered_with #map, is loaded" do
    assert_nothing_raised(NameError) do
      Mappings.map(:klass => 'ClassFromFramework', :framework => 'TheFramework') {}
    end

    # The mapping should not yet exist
    assert_nil Mappings.mappings[:klass]

    # now we actually define the class and fake the loading of the framework
    eval "class ::ClassFromFramework; end"
    Mappings.framework_loaded('TheFramework')

    # It should be loaded by now
    assert_equal ClassFromFramework, Mappings.mappings[:klass].control_class
  end

  def test_should_keep_a_unique_list_of_loaded_frameworks
    frameworks_before = Mappings.loaded_frameworks.length
    Mappings.framework_loaded('TheFramework')
    Mappings.framework_loaded('TheFramework')
    frameworks_after = Mappings.loaded_frameworks.length

    assert (frameworks_after - frameworks_before) == 1
    assert Mappings.loaded_frameworks.include?('theframework')
  end

  def test_should_return_whether_or_not_a_framework_has_been_loaded_yet
    Mappings.framework_loaded('TheFramework')
    assert Mappings.loaded_framework?('TheFramework')

    refute Mappings.loaded_framework?('IHasNotBeenLoaded')
    refute Mappings.loaded_framework?(nil)
    refute Mappings.loaded_framework?('')
  end

end
