# frozen_string_literal: true

module Analyzable
  class ProductLink < ApplicationRecord
    belongs_to :product, class_name: 'Analyzable::Product'
  end
end
