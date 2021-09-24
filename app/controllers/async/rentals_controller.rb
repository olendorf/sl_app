# frozen_string_literal: true

require 'benchmark'

module Async
  # Handles AJAX requests for data to create charts and tables.
  class RentalsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart']).to_json
    end
    
    def parcel_status_treemap
      color_map = {
        'open' =>'#EC2500', 'for_sale' => '#EC9800', 'occupied' => '#9EDE00'
      }
      states = Analyzable::ParcelState.states.keys
      regions = {}
      parcels = current_user.parcels
      parcels.select(:region).distinct.collect do |v| 
        regions[v.region] = 0
      end
      data = {}
      states.each do |state|
        data[state] = regions.clone
      end
      parcels.each do |parcel|
        data[parcel.current_state][parcel.region] += 1
      end
      chart_data = []
      states.each { |state| chart_data << {id: state, name: state.humanize, color: color_map[state]} }
      data.each do |state, h|
        h.each do |region, count|
          chart_data << {parent: state, name: region, value: count}
        end
      end
      chart_data
    end
    
    def region_revenue_bar_chart
      data = current_user.transactions.joins(:parcel).where(
        category: ['tier', 'land_sale'], 
        created_at: (1.month.ago..Time.current)).
            group(:region).sum(:amount).sort_by { |k, v| v }.reverse     
      puts generate_color_map(data.collect { |i| i.first})
      data = {
        regions: data.collect { |i| i.first},
        data: data.collect { |i| i.last },
        colors: generate_color_map(data.collect { |i| i.first}).values
      }
      puts data
      data
    end
    
    
    def parcel_status_timeline
      color_map = {
        'open' =>'#EC2500', 'for_sale' => '#EC9800', 'occupied' => '#9EDE00'
      }
      states = Analyzable::ParcelState.where(
                parcel_id: current_user.parcels.collect { |p| p.id })
      dates = time_series_dates((states.minimum(:created_at) - 3.days), Time.current)
      data = {}
      date_data = {}
      dates.each { |date| date_data[date] = 0 }
      Analyzable::ParcelState.states.keys.each do |state|
        data[state] = date_data.clone
      end
      
      states.each do |state|
        time_series_dates(state.created_at, state.closed_at).each do |date|
          data[state.state][date] += 1 if data[state.state][date]
          if data[state.state][date].nil?
            data[state.state][date] = 1 unless data[state.state][date]
            puts "adding date #{date}"
          end
        end
      end
      
      chart_data = {dates: dates, data: [] }
      
      data.each do |state, data|
        chart_data[:data] << {name: state.humanize, data: data.values, color: color_map[state]}
      end
      chart_data

    end
  
    def rental_income_timeline
      transactions = current_user.transactions.includes(:parcel).where(category: ['tier', 'land_sale'])
      regions = current_user.parcels.select(:region).distinct.collect { |p| p.region }
      dates = time_series_months((transactions.minimum(:created_at) - 2.days), Time.current)
      date_data = {}
      dates.each do |date|
        date_data[date] = 0
      end
      data = {}
      regions.each do |region|
        data[region] = date_data.clone
      end
      transactions.each do |transaction|
        data[transaction.parcel.region][transaction.created_at.strftime('%B %Y')] += transaction.amount
      end
      chart_data = {dates: dates, data: [], colors: (generate_color_map(regions).values)}
      data.each do |region, data|
        chart_data[:data] << {name: region, data: data.values}
      end
      chart_data
      
    end

  end
end
