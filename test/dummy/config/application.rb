# frozen_string_literal: true

# test/dummy/config/application.rb
require_relative "boot"

# Only require the frameworks we need
require "rails"
%w[
  action_controller
  action_view
  rails/test_unit
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require your gem
require "guided_tour"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Configure I18n
    config.i18n.available_locales = [:en, :de]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true

    # If you need assets
    config.assets.enabled = true if config.respond_to?(:assets)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.eager_load = true
  end
end
