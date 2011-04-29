framework 'Foundation'

require 'fileutils'
require 'rbconfig'
require 'yaml'

module HotCocoa

  class ApplicationBuilder

    ##
    # @todo support CFBundleDocumentTypes
    # @todo support CFBundleShortVersionString
    # @todo support NSHumanReadableCopyright
    # @todo support arbitrary info.plist key/value pairs
    # @todo support embedding other gems
    class Configuration

      # Name of the app
      attr_reader :name

      # @return [String] Reverse URL unique identifier
      # @example Identifier for Mail.app
      #  'com.apple.mail'
      attr_reader :identifier

      # @return [String] Version of the app
      attr_reader :version

      # Path to the icon file
      attr_reader :icon

      # @return [Array<String>] Globbing patterns describing where to find
      #  resources that need to be copied into the app bundle
      attr_reader :resources

      # @return [Array<String>] Globbing patterns describing where to find
      #  source code that needs to be copied into the app bundle
      attr_reader :sources

      # @return [Boolean] Whether the app is an daemon with UI or a regular app
      attr_reader :agent

      # @return [Boolean] Whether to include the Ruby stdlib in the app
      attr_reader :stdlib

      # @return [Array<String>] Any `.xcdatamodel` directories to compile and
      #  add to the app bundle
      attr_reader :data_models

      # Four letter code identifying bundle type, the default value is 'APPL'
      # to specify the bundle is an application
      attr_reader :type

      # Four letter code that is a signature of the bundle, defaults to '????'
      # since most apps never set this value
      # @exapmle TextEdit
      #  'ttxt'
      # @example Mail
      #  'emal'
      attr_reader :signature

      # @return [Boolean] Always make a clean build of the app
      attr_reader :overwrite
      alias_method :overwrite?, :overwrite

      # @todo validation (sources should not be an empty array)
      def initialize file
        yml          = YAML.load(File.read(file))
        @name        = yml['name'] # mandatory
        @icon        = yml['icon']
        @identifier  = yml['identifier']  || "com.#{@name}"
        @version     = yml['version']     || '1.0'
        @sources     = yml['sources']     || [] # this should be mandatory?
        @resources   = yml['resources']   || []
        @data_models = yml['data_models'] || []
        @type        = yml['type']        || 'APPL'
        @signature   = yml['signature']   || '????'
        @overwrite   = yml['overwrite'] == true  ? true  : false
        @agent       = yml['agent']     == true  ? '1'   : '0'
        @stdlib      = yml['stdlib']    == false ? false : true
      end

      def icon_exists?
        @icon ? File.exist?(@icon) : false
      end
    end

    # @return [HotCocoa::ApplicationBuilder::Configuration] the cached
    #  app configuration options
    attr_accessor :config

    # @return [Boolean] Whether or not to build the app bundle for deployment
    #  by calling `macruby_deploy` on the generated app bundle
    attr_accessor :deploy
    alias_method  :deploy?, :deploy

    # @return [Array<String>]
    attr_accessor :sources

    # @return [Array<String>]
    attr_accessor :resources

    # @return [Array<String>]
    attr_accessor :data_models

    def self.build config, opts = {}
      options = { deploy: false }.merge opts

      builder        = new
      builder.config = config
      builder.deploy = options[:deploy]

      config.sources.each   { |source| builder.add_source_path(source) }
      config.resources.each { |resource| builder.add_resource_path(resource) }
      config.data_models.each do |data|
        builder.add_data_model(data) if File.extname(data) == '.xcdatamodel'
      end

      builder.build
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
      embed_framework if deploy?
      copy_icon_file if config.icon_exists?
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
      Dir.glob(model).each do |data|
        data_models << data
      end
    end


    private

    def check_for_bundle_root
      FileUtils.rm_rf bundle_root if File.exist?(bundle_root) && config.overwrite?
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
          FileUtils.cp_r resource, destination
        end
      end
    end

    def compile_data_models
      data_models.each do |data|
        `/Developer/usr/bin/momc #{data} #{resources_root}/#{File.basename(data, ".xcdatamodel")}.mom`
      end
    end

    def copy_icon_file
      FileUtils.cp config.icon, icon_file
    end

    def write_pkg_info_file
      File.open(pkg_info_file, 'wb') { |f| f.write "#{config.type}#{config.signature}" }
    end

    def write_info_plist_file
      # http://developer.apple.com/library/mac/#documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html%23//apple_ref/doc/uid/TP40009254-SW1
      info = {
        CFBundleName:                  config.name,
        CFBundleIdentifier:            config.identifier,
        CFBundleVersion:               config.version,
        CFBundlePackageType:           config.type,
        CFBundleSignature:             config.signature,
        CFBundleExecutable:            objective_c_executable_file,
        CFBundleDevelopmentRegion:     'English',
        CFBundleInfoDictionaryVersion: '6.0',
        NSPrincipalClass:              'NSApplication',
        LSUIElement:                   config.agent,
        LSMinimumSystemVersion:        '10.6.7', # should match MacRuby
      }
      info[:CFBundleIconFile] = File.basename(config.icon) if config.icon_exists?

      File.open(info_plist_file, 'w') { |f| f.write info.to_plist }
    end

    def embed_framework
      options = config.stdlib ? '' : '--no-stdlib'
      `macruby_deploy --embed --gem hotcocoa #{options} #{bundle_root}`
    end

    # @todo something better than puts `gcc`
    def build_executable
      File.open(objective_c_source_file, 'wb') do |f|
        f.write %{
          #import <MacRuby/MacRuby.h>

          int main(int argc, char *argv[])
          {
              return macruby_main("rb_main.rb", argc, argv);
          }
        }
      end
      Dir.chdir(macos_root) do
        puts `gcc main.m -o #{objective_c_executable_file} -arch x86_64 -framework MacRuby -framework Foundation -fobjc-gc-only`
      end
      File.unlink(objective_c_source_file)
    end

    # Borrow rb_main from MacRuby Xcode templates
    def write_ruby_main
      File.open(main_ruby_source_file, 'wb') do |f|
        f.write <<-EOF
# Borrowed from the MacRuby sources on April 18, 2011
framework 'Cocoa'

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
dir_path += "/lib/"
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  if path != main
    require File.join(dir_path, path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
        EOF
      end
    end

    def bundle_root
      "#{config.name}.app"
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

    def info_plist_file
      File.join(contents_root, "Info.plist")
    end

    def icon_file
      File.join(resources_root, "#{config.name}.icns")
    end

    def pkg_info_file
      File.join(contents_root, "PkgInfo")
    end

    def objective_c_executable_file
      config.name.gsub(/\s+/, '')
    end

    def objective_c_source_file
      File.join(macos_root, "main.m")
    end

    def main_ruby_source_file
      File.join(resources_root, "rb_main.rb")
    end
  end
end
