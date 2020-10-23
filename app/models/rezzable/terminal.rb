# frozen_string_literal: true

module Rezzable
  # Class for rezzable terminals in SL
  class Terminal < ApplicationRecord
    acts_as :abstract_web_object

    def response_data
      { api_key: api_key }
    end
  end
end
