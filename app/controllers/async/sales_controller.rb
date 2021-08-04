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

    # def visits_histogram(ids)
    #   Analyzable::Visit.select(:duration).where(web_object_id: ids).collect do |v|
    #     v.duration / 60.0
    #   end.compact
    # end

    # def visitors_time_histogram(ids)
    #   Analyzable::Visit.where(web_object_id: ids)
    #                   .group(:avatar_key).sum(:duration).collect do |_k, v|
    #     v / 60.0
    #   end
    # end

    # def visitors_counts_histogram(ids)
    #   Analyzable::Visit.where(web_object_id: ids).group(:avatar_key).count.collect { |_k, v| v }
    # end

    # def visitors_duration_counts_scatter(ids)
    #   counts = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).count
    #   durations = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).sum(:duration)
    #   counts.collect { |k, v| { x: v, y: durations[k] / 60.0, name: k } }
    # end

    # def visits_timeline(ids)
    #   visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    #   dates = time_series_dates(visits.first.start_time - 3.days, Time.current)
    #   visitor_data = visits.collect do |d|
    #     { date: d.start_time.strftime('%F'),
    #       avatar_name: d.avatar_name }
    #   end
    #   visitor_data = visitor_data.group_by { |h| h[:date] }
    #   counts = Array.new(dates.size, 0)
    #   durations = Array.new(dates.size, 0)
    #   visitors = Array.new(dates.size, 0)
    #   visits.each do |v|
    #     index = dates.index(v.start_time.strftime('%F'))
    #     counts[index] += 1
    #     durations[index] += v.duration
    #     visitors[index] = visitor_data[v.start_time.strftime('%F')].size
    #   end
    #   { dates: dates, counts: counts, durations: durations, visitors: visitors }
    # end
    # def visits_heatmap(ids)
    #   visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    #   data = []
    #   (0..23).each { |h| (0..6).each { |d| data << [d, h, 0] } }
    #   visits.each do |visit|
    #     h = visit.start_time.strftime('%k').to_i
    #     d = visit.start_time.strftime('%w').to_i
    #     data[(d * 24) + h][2] = data[(d * 24) + h][2] + 1
    #   end
    #   data
    # end

    # def duration_heatmap(ids)
    #   visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    #   data = []
    #   (0..6).each { |d| (0..23).each { |h| data << [d, h, 0] } }
    #   visits.each do |visit|
    #     h = visit.start_time.strftime('%k').to_i
    #     d = visit.start_time.strftime('%w').to_i
    #     data[(d * 24) + h][2] = data[(d * 24) + h][2] + visit.duration / 60.0
    #   end
    #   data
    # end

    # def visit_location_heatmap(ids)
    #   visits = Analyzable::Visit.includes(:detections).where(web_object_id: ids)
    #   data = []
    #   256.times { |x| 256.times { |y| data << [x, y, 0] } }
    #   visits.each do |visit|
    #     visit.detections.each do |det|
    #       pos = JSON.parse(det.position).transform_values(&:floor)
    #       pos['x'] = 255 if pos['x'] > 255
    #       pos['y'] = 255 if pos['y'] > 255
    #       data[256 * pos['x'] + pos['y']][2] += 0.5
    #     end
    #   end
    #   { data: data, max: data.collect { |d| d[2] }.max }
    # end
    # def time_series_dates(start, stop, interval = 1.day)
    #   dates = []
    #   step_time = start

    #   while step_time <= stop
    #     dates << step_time.strftime('%F')
    #     step_time += interval
    #   end
    #   dates
    # end
  end
end
