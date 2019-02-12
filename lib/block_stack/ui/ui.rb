####################
# Features
####################
# *Opal Support
# *Sprockets Pipeline built in
# *Disparate asset directories (registerable)
# *Support for multiple view directories with cascading
# Default views for: index, show, new, edit, search
# *Inclusion of suite of open source CSS and JS libraries
# *Tag helpers
# Improved HTML builder (from BBLib)
# *Better image handling than default sprockets
# Built in menu system with multiple main menu styles (toggleable)
# Themeable UI
# DFormed support built in
# Custom DFormed presets
# Custom BlockStack Widgets (Javascript)
# UI Widgets (custom render method)

require_relative 'menu/menu'
require_relative 'helpers/general'
require_relative 'helpers/images'
require_relative 'helpers/tags'
require_relative 'blocks/block'
require_relative 'dformed/presets'
require_relative 'templates/general'
require_relative 'templates/crud'
require_relative 'templates/admin'
require_relative 'configuration'

module BlockStack
  class Server < Sinatra::Base

    helpers TagHelper, ImageHelper, GeneralHelper

    # attr_ary_of String, :asset_paths, singleton: true, default_proc: :default_asset_paths, add_rem: true, uniq: true
    attr_of Menu, :menu, default_proc: :build_main_menu, singleton: true

    Opal.use_gem 'bblib'
    Opal.use_gem 'dformed'

    def self.asset_paths
      @asset_paths ||= default_asset_paths
    end

    def self.asset_paths=(paths)
      @asset_paths = [paths].flatten
    end

    def self.add_asset_path(path, index = 0)
      return true if asset_paths.include?(path)
      asset_paths.insert(index, path)
      setup_sprockets
      controllers.each { |c| c.add_asset_path(path, index) }
      auto_load(path)
      return asset_paths.include?(path)
    end

    def self.remove_asset_path(path)
      asset_paths.delete(path)
    end

    def self.api_prefix
      @api_prefix ||= 'api'
    end

    def self.default_asset_paths
      [File.expand_path("../app", __FILE__)]
    end

    # Check to see if a given view would be found by sprockets.
    def self.view?(path)
      # TODO Implement this to prevent having to error handle for default views
      # opal.sprockets.find_asset("views/#{path.to_s.uncapsulate('/')}") ? true : false
    end

    # TODO Add a global render method that checks each engine rather than needing
    # to specify it. Would need config to go with for default engine and prefered engines.

    bridge_method :view?

    def self.maps_app
      @maps_app ||= Opal::SourceMapServer.new(sprockets, config.maps_prefix)
    end

    def self.opal
      exists = @opal
      server = OPAL_LEGACY ? Opal::Server : Opal::Sprockets::Server
      @opal ||= server.new do |s|
        s.append_path "#{File.expand_path('../app', __FILE__)}"
        s.main = 'javascript/application'
      end
      setup_sprockets unless exists
      @opal
    end

    def self.setup_sprockets
      asset_paths.each do |path|
        @opal.append_path(path) if @opal && !@opal.sprockets.paths.include?(path)
      end
    end

    def self.precompile!
      BlockStack.logger.info("BlockStack is compiling assets in #{config.public_folder}...")
      environment = opal.sprockets
      manifest = Sprockets::Manifest.new(environment.index, config.public_folder)
      manifest.compile(config.precompile_assets)
    end

    def self.run!(*args)
      parse_argv
      register_controllers
      controllers.each { |c| c.asset_paths = self.asset_paths }
      precompile! if config.precompile
      logger.info("Booting up your BlockStack UI server...")
      set(:environment, :development) unless environment
      logger.info("Running in #{environment} mode")
      super
    end

    def self.auto_load(base_dir)
      BlockStack.require_all("#{base_dir}/models") if config.auto_load_models
      BlockStack.require_all("#{base_dir}/controllers") if config.auto_load_controllers
    end

    def self.title
      config.app_name || base_server.to_s.split('::').last
    end

    bridge_method :title

    def self.build_main_menu
      menu = Menu.new(
        title: self.title,
        items: {
          title:      'Home',
          icon:       HTML.build(:i, class: 'fas fa-home'),
          sort:       0,
          attributes: {
            href: '/'
          }
        }
      )
      controllers.each do |controller|
        menu.add_items(*controller.sub_menus)
      end
      menu
    end

    helpers do
      def find_template(views, name, engine, &block)
        ((views.is_a?(Array) ? views : []) + self.class.asset_paths).uniq.each { |view| super("#{view}/views", name, engine, &block) }
      end
    end

    get config.maps_prefix do
      maps_app.call(config.maps_prefix)
    end

    get '/assets/*' do
      env['PATH_INFO'].sub!('/assets', '')
      self.class.opal.sprockets.call(env)
    end

    get '/fonts/*' do
      redirect request.path_info.sub('fonts', 'assets/fonts')
    end

  end
end
