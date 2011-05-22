require 'rubygems'
gem     'minitest-macruby-pride'
require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'hotcocoa'

class MiniTest::Unit::TestCase

  def run_run_loop time = 1.0
    NSRunLoop.currentRunLoop.runUntilDate( Time.now + time )
  end

end

class SampleClass
  def some_method
    false
  end
end
