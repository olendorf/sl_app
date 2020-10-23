# frozen_string_literal: true

module Rezzable
  # Class for rezzable terminals in SL
  class Terminal < ApplicationRecord
    acts_as :abstract_web_object

    # rubocop:disable Style/RedundantSelf
    def response_data
      { api_key: self.api_key }
    end
    # rubocop:enable Style/RedundantSelf
  end
end
