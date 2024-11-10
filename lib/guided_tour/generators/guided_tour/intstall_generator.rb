module GuidedTour
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def check_dependencies
        unless File.exist?("package.json")
          say "Installing jsbundling-rails...", :green
          run "rails javascript:install:esbuild"
        end

        unless File.exist?("app/javascript/controllers/index.js")
          say "Installing stimulus-rails...", :green
          run "rails stimulus:install"
        end
      end

      def add_npm_package
        in_root do
          run "yarn add @guided_tour/controllers@#{GuidedTour::VERSION}"
        end
      end

      def update_build_js
        if File.exist?("build.js")
          append_build_config
        else
          template "build.js.tt", "build.js"
        end
      end

      def update_javascript_entry
        inject_into_file "app/javascript/application.js", after: "import \"@hotwired/turbo-rails\"\n" do
          <<-JS
  import { Application } from "@hotwired/stimulus"
  import { controllers } from "@guided_tour/controllers"
  
  // Stimulus setup
  window.Stimulus = Application.start()
  
  // Register GuidedTour controllers
  controllers.forEach(({ name, controller }) => {
    window.Stimulus.register(`guided-tour--${name}`, controller)
  })
          JS
        end
      end

      private

      def append_build_config
        inject_into_file "build.js", after: "entryPoints: [" do
          "\n    './node_modules/@guided_tour/controllers/**/*.js',"
        end
      end
    end
  end
end
