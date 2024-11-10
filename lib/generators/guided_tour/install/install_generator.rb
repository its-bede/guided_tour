# frozen_string_literal: true

require 'guided_tour'

# lib/generators/guided_tour/install/install_generator.rb
# require File.expand_path('../../../guided_tour/version', __dir__)


module GuidedTour
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      def check_dependencies
        unless File.exist?("app/javascript/controllers/index.js")
          say "Installing stimulus-rails...", :green
          run "rails stimulus:install"
        end
      end

      def update_javascript_entry
        inject_into_file "app/javascript/controllers/index.js", after: "import { application } from \"./application\"" do
          <<-JS

// GuidedTour
import { GuidedTourController } from "guided_tour/tour_controller"
application.register('guided-tour--tour', GuidedTourController)

          JS
        end
      end
    end
  end
end