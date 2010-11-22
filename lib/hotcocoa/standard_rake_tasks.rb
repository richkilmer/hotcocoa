AppConfig = HotCocoa::ApplicationBuilder::Configuration.new("config/build.yml")

desc "Build a deployable version of the application"
task :deploy => [:clean] do
  HotCocoa::ApplicationBuilder.build(AppConfig, :deploy => true)
end

desc "Build the application"
task :build do
  HotCocoa::ApplicationBuilder.build(AppConfig)
end

desc "Build and execute the application"
task :run => [:build] do
  require 'open3'
  Open3.popen3("./#{AppConfig.name}.app/Contents/MacOS/#{AppConfig.name.gsub(/ /, '')} 2>&1") do |stdin, stdout, stderr|
    loop do
      break if(stdout.closed?)
      if IO.select([stdout], nil, nil, 0.1)
        begin
          print(stdout.readpartial(4096))
        rescue EOFError
          break
        end
        $stdout.flush
      end
    end
  end
end

desc "Cleanup build files"
task :clean do
  `/bin/rm -rf "#{AppConfig.name}.app"`
end
