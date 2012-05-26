require 'fileutils'
require 'rbconfig'

module HotCocoa
  class Template
    
    def self.source_directory
      File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    end
    
    def self.copy_to(directory, app_name)
      FileUtils.mkdir_p(directory)
      Dir.glob(File.join(source_directory, "template", "**/*")).each do |file|
        short_name = file[(source_directory.length+10)..-1]
        if File.directory?(file)
          FileUtils.mkdir_p File.join(directory, short_name)
        else
          File.open(File.join(directory, short_name), "w") do |out|
            is_icon_file = File.extname(file)[1..-1] == "icns"
            format = is_icon_file ?  "BINARY" : "UTF-8"            
            input =  File.open(file, "r:#{format}").read
            input.gsub!(/__APPLICATION_NAME__/, app_name)
            out.write input
          end
        end
      end
    end
  end
end