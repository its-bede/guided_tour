# frozen_string_literal: true

module GuidedTour
  class Engine < ::Rails::Engine
    isolate_namespace GuidedTour

    # Add a class method to easily get the JavaScript path
    def self.javascript_path
      root.join("app/javascript").to_s
    end

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

    def add_javascript_configuration
      application_js_path = "app/javascript/application.js"

      append_to_file application_js_path do
        "\nimport \"controllers/your_gem/your_controller\"\n"
      end

      # Optionally, modify esbuild configuration if needed
      inject_into_file "package.json", after: "\"scripts\": {" do
        <<-JSON
        "build:gem": "esbuild app/javascript/*.* #{gem_javascript_paths} --bundle --sourcemap --outdir=app/assets/builds",
        JSON
      end
    end

    private

    def gem_javascript_paths
      spec = Gem::Specification.find_by_name("your_gem")
      "#{spec.gem_dir}/app/javascript/**/*.*"
    end
  end
end
