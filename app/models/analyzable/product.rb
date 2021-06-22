# frozen_string_literal: true

module Analyzable
  class Product < ApplicationRecord
    
    before_save :add_link
    
    has_many :product_links, class_name: 'Analyzable::ProductLink'
    has_many :sales, class_name: 'Analyzable::Transaction', dependent: :nullify
    
    belongs_to :user
    
    
    def add_link
      unless  product_links.find_by_link_name(product_name)
        product_links << Analyzable::ProductLink.create(
          link_name: product_name
          )
      end
    end
  end
end
