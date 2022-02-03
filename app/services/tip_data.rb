# frozen_string_literal: true

# Handles data processing for parcels
class TipData
  include DataHelper

  def self.tips_timeline(current_user)
    tips = current_user.tips.order(:created_at)
    dates = time_series_dates(tips.first.created_at - 1.day, Time.current)
    counts = Array.new(dates.size, 0)
    amounts = Array.new(dates.size, 0)
    tips.each do |t|
      index = dates.index(t.created_at.strftime('%F'))
      if index
        counts[index] = counts[index] + 1 unless counts[index].nil?
        amounts[index] += t.amount.nil? ? 0 : t.amount if amounts[index]
      end
    end
    { dates: dates, counts: counts, amounts: amounts }
  end
end
