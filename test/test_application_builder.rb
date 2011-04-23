require 'fileutils'
require 'yaml'

require 'hotcocoa/application_builder'

class TestConfiguration < MiniTest::Unit::TestCase

  Configuration = HotCocoa::ApplicationBuilder::Configuration
  TEST_DIR      = File.join( File.dirname(__FILE__), 'test_app_builder' )

  # Some HotCocoa build.yml files, borrowed from projects on Github
  HOTCONSOLE = 'test/fixtures/hotconsole.yml'
  CALCULATOR = 'test/fixtures/calculator.yml'
  STOPWATCH  = 'test/fixtures/stopwatch.yml'
  EMPTY_APP  = 'test/fixtures/empty.yml'

  def setup;    FileUtils.mkdir TEST_DIR; end
  def teardown; FileUtils.rm_rf TEST_DIR; end

  def test_reads_attributes
    conf = Configuration.new HOTCONSOLE
    assert_equal 'HotConsole',                conf.name
    assert_equal '1.0',                       conf.version
    assert_equal 'resources/HotConsole.icns', conf.icon
    assert_equal ['resources/**/*.*'],        conf.resources
    assert_equal ['lib/**/*.rb'],             conf.sources

    conf = Configuration.new CALCULATOR
    assert_equal 'Calculator', conf.name
    assert_equal '2.0', conf.version
  end

  def test_version_defaults_to_1_if_not_set
    conf = Configuration.new STOPWATCH
    refute_nil conf.version
    assert_equal '1.0', conf.version
  end

  def test_sources_resources_and_data_models_are_initialized_to_an_empty_array_if_not_provided
    conf = Configuration.new EMPTY_APP
    assert_empty conf.sources
    assert_empty conf.resources
    assert_empty conf.data_models
  end

  def test_overwirte_attribute
    conf = Configuration.new EMPTY_APP
    refute conf.overwrite?

    conf = Configuration.new STOPWATCH
    assert conf.overwrite?
  end

  def test_agent_attribute
    conf = Configuration.new EMPTY_APP
    assert_equal '0', conf.agent

    conf = Configuration.new STOPWATCH
    assert_equal '1', conf.agent
  end

  def test_stdlib_attribute
    conf = Configuration.new HOTCONSOLE
    assert_equal true, conf.stdlib

    conf = Configuration.new STOPWATCH
    assert_equal false, conf.stdlib
  end

  def test_icon_exists?
    conf = Configuration.new HOTCONSOLE
    refute conf.icon_exists?

    # works because this project uses the icon from a system app
    conf = Configuration.new CALCULATOR
    assert conf.icon_exists?
  end

end
