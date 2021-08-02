# frozen_string_literal: true

module Analyzable
  # Acts as hub for different related inventories. Links them together
  # using ProductLinks by name. It will also link things like market place
  # items.
  class Product < ApplicationRecord
    before_save :add_link

    has_many :product_links, class_name: 'Analyzable::ProductLink'
    accepts_nested_attributes_for :product_links, allow_destroy: true
    has_many :sales, class_name: 'Analyzable::Transaction', dependent: :nullify

    belongs_to :user

    def add_link
      return if product_links.find_by_link_name(product_name)

      product_links << Analyzable::ProductLink.create(
        link_name: product_name
      )
    end

    def inventories
      inventory_names = product_links.collect(&:link_name)
      user.inventories.where(inventory_name: inventory_names)
    end
  end
end
