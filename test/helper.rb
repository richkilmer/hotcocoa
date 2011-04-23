require 'rubygems'
require 'stringio'
gem     'minitest-macruby-pride'
require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'hotcocoa'

class SampleClass
end
