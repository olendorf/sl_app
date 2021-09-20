class Analyzable::ParcelDecorator < Draper::Decorator
  delegate_all
  
  def slurl
    position = JSON.parse(self.position)
    href = "https://maps.secondlife.com/secondlife/#{region}/#{position['x'].round}/" \
           "#{position['y'].round}/#{position['z'].round}/"
    text = "#{region} (#{position['x'].round}, " \
           "#{position['y'].round}, #{position['z'].round})"
    h.link_to(text, href)
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
