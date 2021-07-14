# frozen_string_literal: true

module Analyzable
  # Links different inventories together into a product.
  class ProductLink < ApplicationRecord
    validates :link_name, uniqueness: { scope: :user_id }
    belongs_to :product, class_name: 'Analyzable::Product', counter_cache: true
    belongs_to :user
  end
end
