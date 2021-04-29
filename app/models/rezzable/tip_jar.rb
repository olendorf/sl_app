# frozen_string_literal: true

module Rezzable
  class TipJar < ApplicationRecord
    acts_as :abstract_web_object

    enum access_mode: {
      access_mode_all: 0,
      access_mode_group: 1,
      access_mode_list: 2
    }
  end
end
