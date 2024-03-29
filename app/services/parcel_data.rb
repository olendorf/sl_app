# frozen_string_literal: true

# Handles data processing for parcels
class ParcelData
  include DataHelper

  def self.parcel_status_treemap(current_user)
    states = Analyzable::RentalState.states.except('for_rent').keys
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
    states.each do |state|
      chart_data << { id: state, name: state.humanize, color: stop_light_color_map[state] }
    end
    data.each do |state, h|
      h.each do |region, count|
        chart_data << { parent: state, name: region, value: count }
      end
    end
    chart_data
  end

  def self.region_revenue_bar_chart(current_user)
    data = current_user.transactions.joins(:parcel).where(
      category: %w[tier land_sale],
      created_at: (1.month.ago..Time.current)
    ).group(:region).sum(:amount).sort_by { |_k, v| v }.reverse
    {
      regions: data.collect(&:first),
      data: data.collect(&:last),
      colors: generate_color_map(data.collect(&:first)).values
    }
  end

  # def self.region_revenue_bar_chart(current_user)
  #   data = current_user.transactions.joins(:parcel).where(
  #     category: %w[tier land_sale],
  #     created_at: (1.month.ago..Time.current)
  #   ).group(:region).sum(:amount).sort_by { |_k, v| v }.reverse
  #   {
  #     regions: data.collect(&:first),
  #     data: data.collect(&:last),
  #     colors: generate_color_map(data.collect(&:first)).values
  #   }
  # end

  def self.parcel_status_timeline(current_user)
    states = Analyzable::RentalState.where(
      rentable_id: current_user.parcels.collect(&:id),
      rentable_type: 'Analyzable::Parcel'
    )
    dates = time_series_dates((states.minimum(:created_at) - 3.days), Time.current)
    data = {}
    date_data = {}
    dates.each { |date| date_data[date] = 0 }
    Analyzable::RentalState.states.except('for_rent').each_key do |state|
      data[state] = date_data.clone
    end

    states.each do |state|
      time_series_dates(state.created_at, state.closed_at).each do |date|
        data[state.state][date] += 1 if data[state.state][date]
        # if data[state.state][date].nil?
        #   data[state.state][date] = 1 unless data[state.state][date]
        #   # puts "adding date #{date}"
        # end
      end
    end

    chart_data = { dates: dates, data: [] }

    data.each do |state, d|
      chart_data[:data] << { name: state.humanize, data: d.values,
                             color: stop_light_color_map[state] }
    end
    chart_data
  end

  def self.parcel_status_ratio_timeline(current_user)
    states = Analyzable::RentalState.where(
      rentable_id: current_user.parcels.collect(&:id),
      rentable_type: 'Analyzable::Parcel'
    )
    dates = time_series_dates((states.minimum(:created_at) - 3.days), Time.current)
    data = {}
    date_data = {}
    date_totals = {}
    dates.each do |date|
      date_data[date] = 0
      date_totals[date] = 0
    end
    Analyzable::RentalState.states.except('for_rent').each_key do |state|
      data[state] = date_data.clone
    end

    states.each do |state|
      time_series_dates(state.created_at, state.closed_at).each do |date|
        data[state.state][date] += 1 if data[state.state][date]
        date_totals[date] += 1 if date_totals[date]
        # if data[state.state][date].nil?
        #   data[state.state][date] = 1 unless data[state.state][date]
        #   # puts "adding date #{date}"
        # end
      end
    end

    date_totals.each do |date, total|
      stop_light_color_map.each_key do |state|
        data[state][date] = (100 * data[state][date].to_f / total.to_f) if data[state]
      end
    end

    chart_data = { dates: dates, data: [] }

    data.each do |state, d|
      chart_data[:data] << { name: state.humanize, data: d.values,
                             color: stop_light_color_map[state] }
    end
    chart_data
  end

  def self.rental_income_timeline(current_user)
    transactions = current_user.transactions.where(category: %w[tier land_sale])
    regions = current_user.parcels.select(:region).distinct.collect(&:region)
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
      data[transaction.transactable.region][
        transaction.created_at.strftime('%B %Y')] += transaction.amount if data[
                                                      transaction.transactable.region][
                                                        transaction.created_at.strftime('%B %Y')]
    end
    chart_data = { dates: dates, data: [], colors: generate_color_map(regions).values }
    data.each do |region, d|
      chart_data[:data] << { name: region, data: d.values }
    end
    chart_data
  end
end
