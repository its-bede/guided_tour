# frozen_string_literal: true

module GuidedTour
  class Engine < ::Rails::Engine
    isolate_namespace GuidedTour

    # Verify dependencies are installed
    config.after_initialize do |app|
      begin
        require "stimulus-rails"
      rescue LoadError
        raise "GuidedTour requires stimulus-rails to be installed. Add `gem 'stimulus-rails'` to your Gemfile."
      end

      # Only check for package.json in non-test environments
      unless Rails.env.test?
        unless File.exist?(Rails.root.join("package.json"))
          raise "GuidedTour requires jsbundling-rails to be installed. Run `rails javascript:install:esbuild`"
        end
      end
    end

    # Initialize locales
    initializer 'guided_tour.locales' do |app|
      app.config.i18n.load_path += Dir[
        Engine.root.join('config', 'locales', '**', '*.{rb,yml}').to_s
      ]
    end

    # Make helper available to app
    initializer 'guided_tour.action_controller' do |_app|
      ActiveSupport.on_load :action_controller do
        helper GuidedTour::ApplicationHelper if defined?(GuidedTour::ApplicationHelper)
      end
    end

    # Make stimulus controllers available to app
    initializer "guided_tour.assets" do |app|
      if app.config.respond_to?(:assets)
        # Add your JavaScript path to assets
        app.config.assets.paths << root.join("app/javascript").to_s
        app.config.assets.precompile += %w[guided_tour/application.js]
      end

      # Add the controllers path to esbuild/webpack paths
      if app.config.respond_to?(:javascript_path)
        app.config.javascript_path << root.join("app/javascript").to_s
      end
    end

    # Hook into importmap if it's being used
    initializer "guided_tour.importmap", before: "importmap" do |app|
      if defined?(ImportMap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
  end
end
