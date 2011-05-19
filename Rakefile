task :default => :build

require 'rake/compiletask'
Rake::CompileTask.new do |t|
  t.files   = FileList["lib/**/*.rb"]
  t.verbose = true
end

desc 'Clean MacRuby binaries'
task :clean do
  FileList["lib/**/*.rbo"].each do |bin|
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

require 'rake/gempackagetask'
spec = Gem::Specification.load('hotcocoa.gemspec')
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = true
end

require 'rubygems/installer'
task :install => :gem do
  Gem::Installer.new(spec.file_name).install
end

desc 'Start up IRb with Hot Cocoa loaded'
task :console do
  irb = ENV['RUBY_VERSION'] ? 'irb' : 'macirb'
  sh "#{irb} -Ilib -rhotcocoa"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  warn "yard (or a dependency) not available. Install it with: macgem install yard"
end
