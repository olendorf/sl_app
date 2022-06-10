# frozen_string_literal: true

# Handles data processing for parcels
class SalesData
  include DataHelper

  def self.sales_by_inventory_revenue_timeline(current_user)
    sales = current_user.sales.includes(:inventory)
    dates = time_series_months(sales.first.created_at - 1.month, Time.current)
    inventories = current_user.inventories.where('revenue > ?', 0).order(:id)
    data = inventories.order(:revenue).reverse.to_h do |i|
      [i.inventory_name, Array.new(dates.size, 0)]
    end
    sales.each do |s|
      next unless s.inventory

      index = dates.index(s.created_at.strftime('%B %Y'))
      if index
        data[s.inventory.inventory_name][index] += s.amount.nil? ? 0 : s.amount
      end
    end
    data = data.collect { |k, v| { name: k, data: v } }
    { dates: dates, data: data, colors: generate_color_map(
      inventories.collect(&:inventory_name)
    ).values }
  end

  def self.sales_by_inventory_items_timeline(current_user)
    sales = current_user.sales.includes(:inventory)
    dates = time_series_months(sales.first.created_at - 1.month, Time.current)
    inventories = current_user.inventories.where('revenue > ?', 0).order(:id)
    data = inventories.order(:revenue).reverse.to_h do |i|
      [i.inventory_name, Array.new(dates.size, 0)]
    end
    sales.each do |s|
      next unless s.inventory

      index = dates.index(s.created_at.strftime('%B %Y'))
      data[s.inventory.inventory_name][index] += 1 if index
    end
    data = data.collect { |k, v| { name: k, data: v } }
    { dates: dates, data: data, colors: generate_color_map(
      inventories.collect(&:inventory_name)
    ).values }
  end

  def self.sales_by_product_items_timeline(current_user)
    sales = current_user.sales.includes(:product)
    dates = time_series_months(sales.first.created_at - 1.month, Time.current)
    products = current_user.products
    data = products.order(:revenue).reverse.to_h do |p|
      [p.product_name, Array.new(dates.size, 0)]
    end
    sales.each do |s|
      next unless s.product

      index = dates.index(s.created_at.strftime('%B %Y'))
      data[s.product.product_name][index] += 1 if index
    end
    data = data.collect { |k, v| { name: k, data: v } }
    {
      dates: dates,
      colors: generate_color_map(
        products.collect(&:product_name)
      ).values,
      data: data
    }
  end

  def self.sales_by_product_revenue_timeline(current_user)
    sales = current_user.sales.includes(:product)
    dates = time_series_months(sales.first.created_at - 1.month, Time.current)
    products = current_user.products
    data = products.order(:revenue).reverse.to_h do |p|
      [p.product_name, Array.new(dates.size, 0)]
    end
    sales.each do |s|
      next unless s.product

      index = dates.index(s.created_at.strftime('%B %Y'))
      if index
        data[s.product.product_name][index] += s.amount.nil? ? 0 : s.amount
      end
    end
    data = data.collect { |k, v| { name: k, data: v } }
    {
      dates: dates,
      colors: generate_color_map(
        products.collect(&:product_name)
      ).values,
      data: data
    }
  end

  def self.vendor_sales_timeline(ids)
    sales_timeline(
      Rezzable::Vendor.find(ids.first).sales.order(:created_at)
    )
  end

  def self.inventory_sales_timeline(ids)
    sales_timeline(
      Analyzable::Inventory.find(ids.first).sales.order(:created_at)
    )
  end

  def self.product_sales_timeline(ids)
    sales_timeline(
      Analyzable::Product.find(ids.first).sales.order(:created_at)
    )
  end

  def self.sales_timeline(sales)
    return {} if sales.size.zero?

    dates = time_series_dates(sales.first.created_at - 3.days, Time.current)
    counts = Array.new(dates.size, 0)
    revenue = Array.new(dates.size, 0)
    sales.each do |s|
      index = dates.index(s.created_at.strftime('%F'))
      counts[index] += 1
      revenue[index] += s.amount
    end
    { dates: dates, counts: counts, revenue: revenue }
  end
end
