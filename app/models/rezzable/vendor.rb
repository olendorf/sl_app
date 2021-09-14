# frozen_string_literal: true

module Rezzable
  # Active record model to for in world vendors
  class Vendor < ApplicationRecord
    attr_accessor :sale

    include RezzableBehavior
    include TransactableBehavior

    before_update :handle_sale, if: :sale?

    acts_as :abstract_web_object

    OBJECT_WEIGHT = 1

    # def response_data
    #   {
    #     api_key: self.api_key
    #   }
    # end

    def transaction_description(transaction)
      "In world purchase by #{transaction.target_name}"
    end

    def transaction_category
      'sale'
    end

    def sale?
      !sale.nil?
    end

    def price
      inventory.price
    end

    def inventory
      server.inventories.find_by_inventory_name(inventory_name)
    end

    def sales
      transactions.where(
        transactable_type: 'Rezzable::Vendor',
        transactable_id: id
      )
    end

    def product_link_id
      product_link.nil? ? nil : product.id
    end

    def product_link
      Analyzable::ProductLink.where(
        product_id: user.products.collect(&:id)
      ).find_by_link_name(inventory.inventory_name)
    end

    def product
      product_link.nil? ? nil : product_link.product
    end

    def handle_revenue
      inv = inventory
      inv.revenue = inv.revenue + price
      inv.save

      self.revenue = revenue + price
      save

      prod = product
      return unless prod

      prod.revenue = prod.revenue + price
      prod.save
    end

    def handle_sale
      data = sale.with_indifferent_access
      self.sale = nil

      Analyzable::Transaction.create(
        amount: price,
        category: 'sale',
        user_id: user.id,
        transactable_id: id,
        transactable_type: 'Rezzable::Vendor',
        description: "Sale of #{inventory_name} to #{data['customer_name']}",
        target_name: data['customer_name'],
        target_key: data['customer_key'],
        inventory_id: inventory.id,
        product_id: product_link_id
      )
      handle_revenue
    end
  end
end
