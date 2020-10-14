# frozen_string_literal: true

module Rezzable
  # Mostly a test for Abstract Web Objects.
  class WebObject < ApplicationRecord
    acts_as :abstract_web_object
  end
end
