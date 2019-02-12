module BlockStack
  class Server < Sinatra::Base
    # This object holds all of the configuration for a server.
    class Configuration < BBLib::HashStruct
      include BBLib::Effortless

      # UI Engine Configuration
      attr_bool :precompile, default: false
      attr_ary_of [String], :precompile_assets, defaut: %w(stylesheets/*.css application.rb javascript/*.js *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)
      attr_str :public_folder
      attr_str :assets_prefix, default: '/assets/'
      attr_str :maps_prefix, default: '/__OPAL_SOURCE_MAPS__'
      attr_sym :default_renderer, default: :slim

      # Server configuration
      attr_bool :auto_load_models, default: true
      attr_bool :auto_load_controllers, default: true

      # UI Display
      attr_sym :navbar, default: :default
      attr_str :time_format, default: '%B %d, %Y %H:%M:%S'
      attr_str :date_format, default: '%B %d, %Y'
    end
  end
end
