# frozen_string_literal: true

# Handles data processing for shop rentals
class ShopData
  include DataHelper

  def self.shop_status_barchart(current_user)
    rental_boxes = current_user.shop_rental_boxes
    regions = rental_boxes.group(:region).count.keys
    states = rental_boxes.group(:current_state).count.keys

    data = {}
    states.each do |state|
      data[state] =
        { name: state.humanize, color: stop_light_color_map[state],
          data: Array.new(regions.size, 0) }
    end

    rental_boxes.each do |box|
      data[box.current_state][:data][regions.index(box.region)] += 1
    end

    {
      regions: regions,
      data: data.values
    }
  end

  def self.shop_renters(current_user)
    data = []
    shops_rent = current_user.shop_rental_boxes.where.not(renter_name: nil)
                             .group(:renter_key).sum(:weekly_rent)
    shops_count = current_user.shop_rental_boxes.where.not(renter_name: nil)
                              .group(:renter_name, :renter_key).count
    shops_count.each do |renter|
      data << {
        renter_name: renter.first.first,
        renter_key: renter.first.second,
        shops: renter.second,
        weekly_rent: shops_rent[renter.first.second]
      }
    end
    data.sort_by { |d| d[:weekly_rent] }.reverse
  end

  def self.shop_status_timeline(current_user)
    states = Analyzable::RentalState.where(
      rentable_id: current_user.shop_rental_boxes.collect(&:id),
      rentable_type: 'Rezzable::ShopRentalBox'
    )
    dates = time_series_dates((states.minimum(:created_at) - 3.days), Time.current)
    data = {}
    date_data = {}
    dates.each { |date| date_data[date] = 0 }
    Analyzable::RentalState.states.except('open', 'for_sale').each_key do |state|
      data[state] = date_data.clone
    end

    states.each do |state|
      time_series_dates(state.created_at, state.closed_at).each do |date|
        data[state.state][date] += 1 if data[state.state][date]
      end
    end

    chart_data = { dates: dates, data: [] }

    data.each do |state, d|
      chart_data[:data] << { name: state.humanize, data: d.values,
                             color: stop_light_color_map[state] }
    end
    chart_data
  end

  def self.shop_status_ratio_timeline(current_user)
    states = Analyzable::RentalState.where(
      rentable_id: current_user.shop_rental_boxes.collect(&:id),
      rentable_type: 'Rezzable::ShopRentalBox'
    )
    dates = time_series_dates((states.minimum(:created_at) - 3.days), Time.current)
    data = {}
    date_data = {}
    date_totals = {}
    dates.each do |date|
      date_data[date] = 0
      date_totals[date] = 0
    end
    Analyzable::RentalState.states.except('open', 'for_sale').each_key do |state|
      data[state] = date_data.clone
    end

    states.each do |state|
      time_series_dates(state.created_at, state.closed_at).each do |date|
        data[state.state][date] += 1 if data[state.state][date]
        date_totals[date] += 1 if date_totals[date]
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

  def self.region_revenue_bar_chart(current_user)
    data = {}

    payments = current_user.transactions.where(category: 'shop_rent')
                           .where(created_at: (1.month.ago..Time.current))
    # shops = payments.collect { |payment| payment.transactable }
    shops = current_user.shop_rental_boxes.where(id: payments.collect(&:transactable_id))
    regions = shops.collect(&:region).uniq

    data = {}

    regions.each { |region| data[region] = 0 }

    payments.each do |payment|
      data[payment.transactable.region] += payment.amount
    end

    data = data.sort_by { |_k, v| -v }

    {
      regions: data.collect(&:first),
      data: data.collect(&:last),
      colors: generate_color_map(data.collect(&:first)).values
    }
  end

  def self.rental_income_timeline(current_user)
    payments = current_user.transactions.where(category: 'shop_rent')
    shops = current_user.shop_rental_boxes.where(id: payments.collect(&:transactable_id))
    regions = shops.collect(&:region)
    dates = time_series_months((payments.minimum(:created_at) - 2.days), Time.current)
    date_data = {}
    dates.each do |date|
      date_data[date] = 0
    end
    data = {}
    regions.each do |region|
      data[region] = date_data.clone
    end
    payments.each do |payment|
      data[payment.transactable.region][
        payment.created_at.strftime('%B %Y')] += payment.amount if data[
                                                      payment.transactable.region][
                                                        payment.created_at.strftime('%B %Y')]
    end
    chart_data = { dates: dates, data: [], colors: generate_color_map(regions).values }
    data.each do |region, d|
      chart_data[:data] << { name: region, data: d.values }
    end
    chart_data
  end
end
