# frozen_string_literal: true

# Decorates user model to provide display helpers and such
class UserDecorator < Draper::Decorator
  delegate_all

  def business_display_name
    business_name.nil? ? user.avatar_name : user.business_name
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
