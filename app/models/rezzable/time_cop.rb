# frozen_string_literal: true

module Rezzable
  # Handles model for Rezzable Timecops
  class TimeCop < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior

    OBJECT_WEIGHT = 4
  end
end
