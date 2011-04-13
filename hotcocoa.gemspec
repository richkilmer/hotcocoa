$LOAD_PATH.unshift File.expand_path 'lib'
require 'hotcocoa/version'

Gem::Specification.new do |s|
  s.name    = 'hotcocoa'
  s.version = Hotcocoa::VERSION

  s.summary       = 'Cococa mapping library for MacRuby'
  s.description   =<<-EOS
HotCocoa is a Cocoa mapping library for MacRuby.  It simplifies the use of complex Cocoa classes using DSL techniques.
  EOS
  s.author        = ['Richard Kilmer', 'Mark Rada']
  s.email         = ['rich@infoether.com', 'mrada@marketcircle.com']
  s.homepage      = 'http://github.com/ferrous26/hotcocoa'
  s.licenses      = ['MIT']

  s.require_paths    = ['lib']
  s.bindir           = ['bin']
  s.executables      = ['hotcocoa']

  s.files            = Dir.glob("{lib,template,test,bin}/**/*") + ['History.txt']
  s.test_files       = Dir.glob('test/**/test_*.rb')
  s.extra_rdoc_files = [ 'Rakefile', 'README.rdoc' ]

  s.add_development_dependency 'minitest-macruby-pride',  ['~> 2.1.2']
end
