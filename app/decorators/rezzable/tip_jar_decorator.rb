# frozen_string_literal: true

module Rezzable
  # Decorator for TipJar model
  class TipJarDecorator < AbstractWebObjectDecorator
    delegate_all

    def time_logged_in
      return nil unless current_session

      ((Time.current - sessions.last.created_at) / 60).round
    end

    # Define presentation-specific methods here. Helpers are accessed through
    # `helpers` (aka `h`). You can override attributes, for example:
    #
    #   def created_at
    #     helpers.content_tag :span, class: 'time' do
    #       object.created_at.strftime("%a %m/%d/%y")
    #     end
    #   end
  end
end
