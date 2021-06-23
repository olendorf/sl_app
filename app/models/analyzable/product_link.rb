# frozen_string_literal: true

module Analyzable
  # Links different inventories together into a product.
  class ProductLink < ApplicationRecord
    belongs_to :product, class_name: 'Analyzable::Product'
  end
end
