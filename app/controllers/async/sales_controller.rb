# frozen_string_literal: true

module Async
  # Handles AJAX requests for data to create charts and tables.
  class SalesController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart'], params['ids']).to_json
    end

    # rubocop:disable Metrics/AbcSize
    def sales_by_inventory_revenue_timeline(_ids = nil)
      sales = current_user.sales.includes(:inventory)
      dates = time_series_months(sales.first.created_at - 1.month, Time.current)
      inventories = current_user.inventories.where('revenue > ?', 0)
      data = inventories.order(:revenue).reverse.collect do |i|
        [i.inventory_name, Array.new(dates.size, 0)]
      end.to_h
      sales.each do |s|
        next unless s.inventory

        index = dates.index(s.created_at.strftime('%B %Y'))
        if index
          data[s.inventory.inventory_name][index] += s.amount.nil? ? 0 : s.amount
        end
      end
      data = data.collect { |k, v| { name: k, data: v } }
      { dates: dates, data: data, colors: inventory_colors(inventories) }
    end

    def sales_by_inventory_items_timeline(_ids = nil)
      sales = current_user.sales.includes(:inventory)
      dates = time_series_months(sales.first.created_at - 1.month, Time.current)
      inventories = current_user.inventories.where('revenue > ?', 0)
      data = inventories.order(:revenue).reverse.collect do |i|
        [i.inventory_name, Array.new(dates.size, 0)]
      end.to_h
      sales.each do |s|
        next unless s.inventory

        index = dates.index(s.created_at.strftime('%B %Y'))
        data[s.inventory.inventory_name][index] += 1 if index
      end
      data = data.collect { |k, v| { name: k, data: v } }
      { dates: dates, data: data, colors: inventory_colors(inventories) }
    end

    def inventory_colors(inventories)
      md5 = Digest::MD5.new
      inventories.collect { |p| "##{md5.hexdigest(p.inventory_name)[0..5]}" }
    end

    def sales_by_product_items_timeline(_ids = nil)
      sales = current_user.sales.includes(:product)
      dates = time_series_months(sales.first.created_at - 1.month, Time.current)
      products = current_user.products
      data = products.order(:revenue).reverse.collect do |p|
        [p.product_name, Array.new(dates.size, 0)]
      end.to_h
      sales.each do |s|
        next unless s.product

        index = dates.index(s.created_at.strftime('%B %Y'))
        data[s.product.product_name][index] += 1 if index
      end
      data = data.collect { |k, v| { name: k, data: v } }
      { dates: dates, colors: product_colors(products), data: data }
    end

    def sales_by_product_revenue_timeline(_ids = nil)
      sales = current_user.sales.includes(:product)
      dates = time_series_months(sales.first.created_at - 1.month, Time.current)
      products = current_user.products
      data = products.order(:revenue).reverse.collect do |p|
        [p.product_name, Array.new(dates.size, 0)]
      end.to_h
      sales.each do |s|
        next unless s.product

        index = dates.index(s.created_at.strftime('%B %Y'))
        if index
          data[s.product.product_name][index] += s.amount.nil? ? 0 : s.amount
        end
      end
      data = data.collect { |k, v| { name: k, data: v } }
      { dates: dates, colors: product_colors(products), data: data }
    end

    # rubocop:enable Metrics/AbcSize

    def product_colors(products)
      md5 = Digest::MD5.new
      products.collect { |p| "##{md5.hexdigest(p.product_name)[0..5]}" }
    end

    def vendor_sales_timeline(ids)
      sales_timeline(
        Rezzable::Vendor.find(ids.first).sales.order(:created_at)
      )
    end

    def inventory_sales_timeline(ids)
      sales_timeline(
        Analyzable::Inventory.find(ids.first).sales.order(:created_at)
      )
    end

    def product_sales_timeline(ids)
      sales_timeline(
        Analyzable::Product.find(ids.first).sales.order(:created_at)
      )
    end

    def sales_timeline(sales)
      dates = time_series_dates(sales.first.created_at - 3.days, Time.current)
      counts = Array.new(dates.size, 0)
      sales.each do |s|
        index = dates.index(s.created_at.strftime('%F'))
        counts[index] += 1
      end
      { dates: dates, counts: counts }
    end
  end
end
