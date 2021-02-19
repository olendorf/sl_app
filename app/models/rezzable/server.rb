# frozen_string_literal: true

module Rezzable
  # Model for in world inventory servers
  class Server < ApplicationRecord
    acts_as :abstract_web_object

    has_many :clients, class_name: 'AbstractWebObject'

    # rubocop:disable Style/RedundantSelf
    def response_data
      { api_key: self.api_key }
    end
    # rubocop:enable Style/RedundantSelf
  end
end
