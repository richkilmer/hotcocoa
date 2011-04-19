framework 'Foundation'

require 'fileutils'
require 'rbconfig'
require 'yaml'

module HotCocoa

  class ApplicationBuilder

    class Configuration
      attr_reader :name
      attr_reader :identifier
      attr_reader :version
      attr_reader :icon
      attr_reader :resources
      attr_reader :sources
      attr_reader :info_string
      attr_reader :agent
      attr_reader :stdlib
      attr_reader :data_models
      attr_reader :overwrite
      alias_method :overwrite?, :overwrite

      def initialize file
        yml          = YAML.load(File.read(file))
        @name        = yml['name']
        @identifier  = yml['identifier']
        @icon        = yml['icon']
        @info_string = yml['info_string']
        @version     = yml['version']     || '1.0'
        @sources     = yml['sources']     || []
        @resources   = yml['resources']   || []
        @data_models = yml['data_models'] || []
        @overwrite   = yml['overwrite'] == true  ? true  : false
        @agent       = yml['agent']     == true  ? '1'   : '0'
        @stdlib      = yml['stdlib']    == false ? false : true
      end

      def icon_exists?
        @icon ? File.exist?(@icon) : false
      end
    end

    ApplicationBundlePackage = "APPL????"

    attr_accessor :name
    attr_accessor :identifier
    attr_accessor :sources
    attr_accessor :icon
    attr_accessor :version
    attr_accessor :info_string
    attr_accessor :resources
    attr_accessor :agent
    attr_accessor :stdlib
    attr_accessor :data_models
    attr_accessor :overwrite
    alias_method  :overwrite?, :overwrite
    attr_accessor :deploy
    alias_method  :deploy?, :deploy

    def self.build config, opts = {}
      options = { deploy: false }.merge opts

      builder             = new
      builder.deploy      = options[:deploy]
      builder.name        = config.name
      builder.identifier  = config.identifier
      builder.version     = config.version
      builder.info_string = config.info_string
      builder.overwrite   = config.overwrite?
      builder.agent       = config.agent
      builder.stdlib      = config.stdlib
      builder.icon        = config.icon if config.icon_exists?

      config.sources.each   { |source| builder.add_source_path(source) }
      config.resources.each { |resource| builder.add_resource_path(resource) }
      config.data_models.each do |data|
        next unless File.extname(data) == '.xcdatamodel'
        builder.add_data_model(data)
      end

      builder.build
    end

    # Used by the "Embed MacRuby" Xcode target.
    def self.deploy path
      raise "Given path `#{path}' does not exist" unless File.exist?(path)
      raise "Given path `#{path}' does not look like an application bundle" unless File.extname(path) == '.app'

      deployer = new
      Dir.chdir(File.dirname(path)) do
        deployer.name = File.basename(path, '.app')
        deployer.deploy
      end
    end

    def initialize
      @sources     = []
      @resources   = []
      @data_models = []
    end

    def build
      check_for_bundle_root
      build_bundle_structure
      write_bundle_files
      copy_sources
      copy_resources
      compile_data_models
      deploy if deploy?
      copy_icon_file if icon
    end

    def deploy
      options = "#{ '--no-stdlib --gem hotcocoa' unless stdlib }"
      `macruby_deploy --embed #{options} #{name}.app`
    end

    def add_source_path source_file_pattern
      Dir.glob(source_file_pattern).each do |source_file|
        sources << source_file
      end
    end

    def add_resource_path resource_file_pattern
      Dir.glob(resource_file_pattern).each do |resource_file|
        resources << resource_file
      end
    end

    def add_data_model model
      Dir.glob(model).each { |data| data_models << data }
    end

    private

    def check_for_bundle_root
      if File.exist?(bundle_root) && overwrite?
        `rm -rf #{bundle_root}`
      end
    end

    def build_bundle_structure
      [bundle_root, contents_root, frameworks_root,
       macos_root, resources_root].each do |dir|
        Dir.mkdir(dir) unless File.exist?(dir)
      end
    end

    def write_bundle_files
      write_pkg_info_file
      write_info_plist_file
      build_executable unless File.exist?(File.join(macos_root, objective_c_executable_file))
      write_ruby_main
    end

    def copy_sources
      sources.each do |source|
        destination = File.join(resources_root, source)
        FileUtils.mkdir_p(File.dirname(destination)) unless File.exist?(File.dirname(destination))
        FileUtils.cp_r source, destination
      end
    end

    def copy_resources
      resources.each do |resource|
        destination = File.join(resources_root, resource.split("/")[1..-1].join("/"))
        FileUtils.mkdir_p(File.dirname(destination)) unless File.exist?(File.dirname(destination))

        if resource =~ /\.xib$/
          destination.gsub!(/.xib/, '.nib')
          puts `ibtool --compile #{destination} #{resource}`
        else
          FileUtils.cp_r(resource, destination)
        end
      end
    end

    def compile_data_models
      data_models.each do |data|
        `/Developer/usr/bin/momc #{data} #{resources_root}/#{File.basename(data, ".xcdatamodel")}.mom`
      end
    end

    def copy_icon_file
      FileUtils.cp(icon, icon_file) unless File.exist?(icon_file)
    end

    def write_pkg_info_file
      File.open(pkg_info_file, "wb") {|f| f.write ApplicationBundlePackage}
    end

    def write_info_plist_file
      info = {
        'CFBundleDevelopmentRegion'     => 'English',
        'CFBundleExecutable'            => name.gsub(/ /, ''),
        'CFBundleIdentifier'            => identifier,
        'CFBundleInfoDictionaryVersion' => '6.0',
        'CFBundleName'                  => name,
        'CFBundlePackageType'           => 'APPL',
        'CFBundleSignature'             => '????',
        'CFBundleVersion'               => version,
        'NSPrincipalClass'              => 'NSApplication',
        'LSUIElement'                   => agent
      }
      info['CFBundleIconFile'] = "#{name}.icns" if icon
      info['CFBundleGetInfoString'] = info_string if info_string

      File.open(info_plist_file, 'w') { |f| f.puts info.to_plist }
    end

    def build_executable
      File.open(objective_c_source_file, 'wb') do |f|
        f.puts %{
          #import <MacRuby/MacRuby.h>

          int main(int argc, char *argv[])
          {
              return macruby_main("rb_main.rb", argc, argv);
          }
        }
      end
      puts `cd '#{macos_root}' && gcc main.m -o #{objective_c_executable_file} -arch x86_64 -framework MacRuby -framework Foundation -fobjc-gc-only`
      File.unlink(objective_c_source_file)
    end

    def write_ruby_main
      File.open(main_ruby_source_file, "wb") do |f|
        f.puts "$:.map! { |x| x.sub(/^\\/Library\\/Frameworks/, NSBundle.mainBundle.privateFrameworksPath) }" if deploy?
        f.puts "resources = NSBundle.mainBundle.resourcePath.fileSystemRepresentation"
        f.puts "$:.unshift(resources)"
        f.puts
        f.puts "Dir.glob(\"\#{resources}/**/*.rb\").each do |file|"
        f.puts "  next if file == 'rb_main.rb'"
        f.puts "  require \"\#{file}\""
        f.puts "end"
        f.puts
        f.puts "begin"
        f.puts "  Kernel.const_get('#{name}').new.start"
        f.puts "rescue Exception => e"
        f.puts "  STDERR.puts e.message"
        f.puts "  e.backtrace.each { |bt| STDERR.puts bt }"
        f.puts "end"
      end
    end

    def bundle_root
      "#{name}.app"
    end

    def contents_root
      File.join(bundle_root, "Contents")
    end

    def frameworks_root
      File.join(contents_root, "Frameworks")
    end

    def macos_root
      File.join(contents_root, "MacOS")
    end

    def resources_root
      File.join(contents_root, "Resources")
    end

    def bridgesupport_root
      File.join(resources_root, "BridgeSupport")
    end

    def info_plist_file
      File.join(contents_root, "Info.plist")
    end

    def icon_file
      File.join(resources_root, "#{name}.icns")
    end

    def pkg_info_file
      File.join(contents_root, "PkgInfo")
    end

    def objective_c_executable_file
      name.gsub(/ /, '')
    end

    def objective_c_source_file
      File.join(macos_root, "main.m")
    end

    def main_ruby_source_file
      File.join(resources_root, "rb_main.rb")
    end

    def current_macruby_version
      NSFileManager.defaultManager.pathContentOfSymbolicLinkAtPath(File.join(macruby_versions_path, "Current"))
    end

    def current_macruby_path
      File.join(macruby_versions_path, current_macruby_version)
    end

    def macruby_versions_path
      File.join(macruby_framework_path, "Versions")
    end

    def macruby_framework_path
      "/Library/Frameworks/MacRuby.framework"
    end
  end
end
