require 'rake'
task :default => :test

require 'rake/compiletask'
Rake::CompileTask.new do |t|
  t.files = FileList["lib/**/*.rb"]
  t.verbose = true
end

desc 'Clean MacRuby binaries'
task :clean do
  FileList["lib/**/*.rbo"].each do |bin|
    puts "rm #{bin}"
    rm bin
  end
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.ruby_opts = ['-rhelper']
  t.verbose = true
end

require 'rubygems'
require 'rubygems/builder'
require 'rubygems/installer'
spec = Gem::Specification.load('hotcocoa.gemspec')

desc 'Build the gem'
task :build do Gem::Builder.new(spec).build end

desc 'Build the gem and install it'
task :install => :build do Gem::Installer.new(spec.file_name).install end

desc 'Start up IRb with Hot Cocoa loaded'
task :console do
  irb = ENV['RUBY_VERSION'] ? 'irb' : 'macirb'
  sh "#{irb} -Ilib -rhotcocoa"
end

require 'yard'
YARD::Rake::YardocTask.new
