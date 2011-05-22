AppConfig = HotCocoa::ApplicationBuilder::Configuration.new( 'config/build.yml' )

if MACRUBY_REVISION.match(/^git commit/)
  require 'rake/compiletask'
  Rake::CompileTask.new do |t|
    t.files   = AppConfig.sources.map { |pattern| FileList[pattern] }.flatten
    t.verbose = true
  end
end

desc 'Build a deployable version of the application'
task :deploy do
  HotCocoa::ApplicationBuilder.build AppConfig, deploy: true
end

desc 'Build the application'
task :build do
  HotCocoa::ApplicationBuilder.build AppConfig
end

desc 'Build and execute the application'
task :run => [:build] do
  sh "open '#{AppConfig.name}.app'"
end

desc 'Cleanup build files'
task :clean do
  sh "/bin/rm -rf '#{AppConfig.name}.app'"
end
