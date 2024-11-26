# frozen_string_literal: true

module GuidedTour
  module ApplicationHelper
    # Generate guided tour markup
    # @param map [Hash] target element ids as keys, explantions as values
    # @return [String] the html markups as html_safe
    def guide_through(map)
      tag.div(class: "guided-tour--wrapper", data: {
        controller: "guided-tour--tour",
        guided_tour__tour_next_btn_text_value: t("guided-tour.next-btn-text"),
        guided_tour__tour_prev_btn_text_value: t("guided-tour.prev-btn-text"),
        guided_tour__tour_done_btn_text_value: t("guided-tour.done-btn-text"),
        guided_tour__tour_step_line_text_value: t("guided-tour.step-line")
      }) do
        safe_join([
                    tag.div(class: "guided-tour--starter-btn-wrapper") do
                      safe_join([
                                  tag.button(type: "button", class: "btn btn-primary ms-auto", id: "guidedTourStarterBtn") do
                                    safe_join([
                                                tag.i(class: "bi bi-lightbulb"),
                                                "&nbsp;".html_safe,
                                                t("guided-tour.starter-button-text")
                                              ])
                                  end
                                ])
                    end,
                    tag.div(class: "guided-tour--overlay", data: {
                      guided_tour__tour_target: "overlay",
                      bs_container: "body",
                      bs_toggle: "popover",
                      bs_placement: "bottom",
                      bs_content: ""
                    }),
                    tag.ol(class: "d-none") do
                      safe_join(
                        map.map do |id, guide_text|
                          tag.li(guide_text, data: {
                            guided_tour__tour_target: "explanation",
                            target_element: id
                          })
                        end
                      )
                    end
                  ])
      end.html_safe
    end
  end
end
