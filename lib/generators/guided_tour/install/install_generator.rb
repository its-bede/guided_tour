# frozen_string_literal: true

# lib/generators/guided_tour/install/install_generator.rb
require File.expand_path('../../../guided_tour/version', __dir__)

module GuidedTour
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def check_dependencies
        unless File.exist?("app/javascript/controllers/index.js")
          say "Installing stimulus-rails...", :green
          run "rails stimulus:install"
        end
      end

      def update_javascript_entry
        inject_into_file "app/javascript/controllers/index.js", before: "application.register" do
          <<-JS
// GuidedTour
import { controllers } from "guided_tour"
controllers.forEach(({ name, controller }) => {
  application.register(name, controller)
})

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
          "\n    './app/javascript/controllers/**/*.js',"
        end
      end
    end
  end
end