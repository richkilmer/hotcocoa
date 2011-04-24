AppConfig = HotCocoa::ApplicationBuilder::Configuration.new( 'config/build.yml' )

require 'rake/compiletask'
Rake::CompileTask do |t|
  t.files   = AppConfig.sources.map { |pattern| FileList[pattern] }.flatten
  t.verbose = true
end

task :deploy => [:clean] do
  HotCocoa::ApplicationBuilder.build(AppConfig, deploy: true)
desc 'Build a deployable version of the application'
end

desc 'Build the application'
task :build do
  HotCocoa::ApplicationBuilder.build AppConfig
end

desc 'Build and execute the application'
task :run => [:build] do
  `open "#{AppConfig.name}.app"`
end

desc 'Cleanup build files'
task :clean do
  `/bin/rm -rf "#{AppConfig.name}.app"`
end
