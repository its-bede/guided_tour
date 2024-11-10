# frozen_string_literal: true

# test/support/translation_helper.rb
module TranslationHelper
  def assert_translated_text(selector, key, locale: I18n.locale)
    expected = I18n.t(key, locale: locale)
    assert_select selector, expected
  end
end

class ActionDispatch::IntegrationTest
  include TranslationHelper
end
