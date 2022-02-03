# frozen_string_literal: true

module Async
  # Handles AJAX requests for tip data
  class TipsController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart']).to_json
    end

    def tips_histogram
      current_user.tips.collect(&:amount)
    end

    def tippers_histogram
      current_user.tips.group(:target_name).sum(:amount).collect { |_k, v| v }
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

    def tips_timeline
      TipData.tips_timeline(current_user)
    end
  end
end
