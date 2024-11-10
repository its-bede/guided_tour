# frozen_string_literal: true

# lib/generators/guided_tour/install/install_generator.rb
require File.expand_path('../../../guided_tour/version', __dir__)

module GuidedTour
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __dir__)  # Note the path change here

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

      def copy_javascript_files
        say "Copying Stimulus controllers...", :green
        directory "javascript/controllers", "app/javascript/controllers/guided_tour"
      end

      def update_javascript_entry
        inject_into_file "app/javascript/application.js", after: "import \"@hotwired/turbo-rails\"\n" do
          <<-JS
import { Application } from "@hotwired/stimulus"
import GuidedTourController from "./controllers/guided_tour/tour_controller"

// Stimulus setup
window.Stimulus = Application.start()

// Register GuidedTour controller
window.Stimulus.register("guided-tour", GuidedTourController)
          JS
        end
      end

      def update_build_js
        if File.exist?("build.js")
          append_build_config
        else
          template "build.js.tt", "build.js"
        end
      end

      private

      def append_build_config
        inject_into_file "build.js", after: "entryPoints: [" do
          "\n    './app/javascript/controllers/guided_tour/**/*.js',"
        end
      end
    end
  end
end
