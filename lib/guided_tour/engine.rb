# frozen_string_literal: true

require_relative '../../app/helpers/guided_tour/application_helper'

# lib/guided_tour/engine.rb
module GuidedTour
  class Engine < ::Rails::Engine
    isolate_namespace GuidedTour

    # Verify dependencies are installed
    config.after_initialize do |_app|
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
    initializer "guided_tour.locales" do |app|
      app.config.i18n.load_path += Dir[
        Engine.root.join("config", "locales", "**", "*.{rb,yml}").to_s
      ]
    end

    initializer 'guided_tour.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper GuidedTour::ApplicationHelper
      end
    end
  end
end
