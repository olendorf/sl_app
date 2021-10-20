# frozen_string_literal: true

module Async
  # Handles AJAX requests for tip data
  class TipsController < AsyncController
    def index
      authorize :async, :index?
      # ids = Rezzable::TipJars.where(user_id: current_user.id, id: params['ids'])
      render json: send(params['chart']).to_json
    end

    def tips_histogram
      current_user.tips.collect(&:amount)
    end

    def tippers_histogram
      # counts = current_user.tips.group(:target_name).count.collect { |k, v| v }
      current_user.tips.group(:target_name).sum(:amount).collect { |_k, v| v }
      # {number_of_tips: counts, total_tipped: totals}
    end

    def sessions_histogram
      current_user.sessions.collect(&:duration)
    end

    def employee_time_histogram
      current_user.sessions.group(:avatar_name).sum(:duration).collect { |_k, v| v }
    end

    def employee_tip_counts_histogram
      current_user.tips.joins(:session).group(:avatar_name).count.collect { |_k, v| v }
    end

    def employee_tip_totals_histogram
      current_user.tips.joins(:session).group(:avatar_name).sum(:amount).collect { |_k, v| v }
    end

    # rubocop:disable Metrics/AbcSize
    def tips_timeline
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

    # rubocop:enable Metrics/AbcSize
  end
end
