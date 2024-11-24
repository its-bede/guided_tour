# frozen_string_literal: true

# lib/generators/guided_tour/install/install_generator.rb
module GuidedTour
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def check_dependencies
        unless File.exist?("app/javascript/controllers/index.js")
          say "Installing stimulus-rails...", :green
          run "rails stimulus:install"
        end
      end

      def add_javascript
        if File.exist?("config/importmap.rb")
          append_to_file "config/importmap.rb" do
            'pin "@itsbede/guided-tour"'
          end
        end

        if File.exist?("package.json")
          run "yarn add @itsbede/guided-tour"
        end
      end

      def add_controller_to_application_js
        inject_into_file "app/javascript/controllers/application.js",
                         before: "export { application }" do
          <<~JAVASCRIPT
            import GuidedTourController from "@itsbede/guided-tour"
            application.register('guided-tour--tour', GuidedTourController)

          JAVASCRIPT
        end
      end
    end
  end
end