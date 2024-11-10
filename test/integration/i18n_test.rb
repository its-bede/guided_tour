# frozen_string_literal: true

# test/integration/i18n_test.rb
require 'test_helper'

class I18nTest < ActionDispatch::IntegrationTest
  def test_locale_switching
    get '/test_page'
    assert_equal 'en', I18n.locale.to_s

    I18n.locale = :de
    get '/test_page'
    assert_equal 'de', I18n.locale.to_s
  end
end