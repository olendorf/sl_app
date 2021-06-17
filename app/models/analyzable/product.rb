# frozen_string_literal: true

module Analyzable
  class Product < ApplicationRecord
    has_many :product_links, class_name: 'Analyzable::ProductLink'
    belongs_to :user
  end
end
