class Rezzable::Terminal < ApplicationRecord
  acts_as :abstract_web_object

  def response_data
    { api_key: self.api_key }
  end
end
