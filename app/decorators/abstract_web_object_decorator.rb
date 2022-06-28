# frozen_string_literal: true

# Base decorator class for web objects.
class AbstractWebObjectDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def slurl
    position = JSON.parse(self.position)
    href = "https://maps.secondlife.com/secondlife/#{region}/#{position['x'].round}/" \
           "#{position['y'].round}/#{position['z'].round}/"
    text = "#{region} (#{position['x'].round}, " \
           "#{position['y'].round}, #{position['z'].round})"
    h.link_to(text, href)
  end

  def semantic_version
    "#{major_version}.#{minor_version}.#{patch_version}"
  end
  
  def format_pay_hint(value)
    return "Hidden" if value == -1
    return "Default" if value == -2
    "L$ #{value}"
  end

  def pretty_active
    return 'active' if active?

    'inactive'
  end
end
