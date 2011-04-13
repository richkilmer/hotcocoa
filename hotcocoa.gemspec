$LOAD_PATH.unshift File.expand_path 'lib'
require 'hotcocoa/version'

spec = Gem::Specification.new do |s|
  s.name = 'hotcocoa'
  s.version = Hotcocoa::VERSION

  s.platform = Gem::Platform::RUBY
  s.summary = "Cococa mapping library for MacRuby"
  s.description = "HotCocoa is a Cocoa mapping library for MacRuby.  It simplifies the use of complex Cocoa classes using DSL techniques."
  s.files = Dir.glob("{lib,template,test,bin}/**/*") + ['History.txt']
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.default_executable = 'hotcocoa'
  s.executables = ['hotcocoa']
  s.author = "Richard Kilmer"
  s.email = "rich@infoether.com"
  s.rubyforge_project = "hotcocoa"
  s.homepage = "http://github.com/richkilmer/hotcocoa"

end

if $0==__FILE__
  Gem::Builder.new(spec).build
end
