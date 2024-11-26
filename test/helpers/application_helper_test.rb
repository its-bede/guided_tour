# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include GuidedTour::ApplicationHelper

  def test_guide_through_generates_correct_markup
    # Given
    map = {
      "reports" => "Report explanation text",
      "report-details" => "Details explanation text"
    }

    # When
    result = guide_through(map)

    # Then
    assert_kind_of ActiveSupport::SafeBuffer, result

    # Parse the generated HTML for better assertions
    doc = Nokogiri::HTML.fragment(result)

    # Test the wrapper div
    wrapper = doc.at_css(".guided-tour--wrapper")
    assert wrapper

    assert_equal "guided-tour--tour", wrapper["data-controller"]
    assert_equal t("guided-tour.next-btn-text"), wrapper["data-guided-tour--tour-next-btn-text-value"]
    assert_equal t("guided-tour.prev-btn-text"), wrapper["data-guided-tour--tour-prev-btn-text-value"]
    assert_equal t("guided-tour.done-btn-text"), wrapper["data-guided-tour--tour-done-btn-text-value"]
    assert_equal t("guided-tour.step-line"), wrapper["data-guided-tour--tour-step-line-text-value"]

    # Test the overlay div
    overlay = doc.at_css(".guided-tour--overlay")
    assert overlay
    assert_equal "overlay", overlay["data-guided-tour--tour-target"]
    assert_equal "body", overlay["data-bs-container"]
    assert_equal "popover", overlay["data-bs-toggle"]
    assert_equal "bottom", overlay["data-bs-placement"]
    assert_equal "", overlay["data-bs-content"]

    # Test the ordered list and its items
    ol = doc.at_css("ol.d-none")
    assert ol

    # Test list items
    lis = ol.css("li")
    assert_equal 2, lis.length

    # Test first list item
    assert_equal "explanation", lis[0]["data-guided-tour--tour-target"]
    assert_equal "reports", lis[0]["data-target-element"]
    assert_equal "Report explanation text", lis[0].text.strip

    # Test second list item
    assert_equal "explanation", lis[1]["data-guided-tour--tour-target"]
    assert_equal "report-details", lis[1]["data-target-element"]
    assert_equal "Details explanation text", lis[1].text.strip
  end
end
