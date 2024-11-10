# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
require "rails/test_help"
require "minitest/autorun"

# Configure I18n for testing
I18n.available_locales = [:en, :de]
I18n.default_locale = :en
I18n.load_path += Dir[
  GuidedTour::Engine.root.join('config', 'locales', '**', '*.{rb,yml}')
]
I18n.reload!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end

class ViewTestCase < ActionView::TestCase
  include ActionView::Helpers
  include ActionView::Context

  setup do
    # Reset locale before each test
    I18n.locale = I18n.default_locale
  end

  # Helper method to switch locales in tests
  def with_locale(locale)
    original_locale = I18n.locale
    I18n.locale = locale
    yield
  ensure
    I18n.locale = original_locale
  end
end