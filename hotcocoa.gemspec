require 'rubygems'

spec = Gem::Specification.new do |s|

  s.name = 'hotcocoa'
  s.version = "0.0.5"
  s.platform = Gem::Platform::RUBY
  s.summary = "Cococa mapping library for MacRuby"
  s.files = Dir.glob("lib/**/*.rb")
  s.require_path = 'lib'

  s.author = "Richard Kilmer"
  s.email = "rich@infoether.com"
  s.rubyforge_project = "hotcocoa"
  s.homepage = "http://www.rubyforge.org/projects/hotcocoa"

end

if $0==__FILE__
  Gem::Builder.new(spec).build
end
