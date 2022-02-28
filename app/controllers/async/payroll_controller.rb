# frozen_string_literal: true

module Async
  # Handles AJAX requests for shop data
  class PayrollController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart']).to_json
    end
    
    def payroll_timeline
      PayrollData.payroll_timeline(current_user)
    end
    
    def hours_heatmap
      PayrollData.hours_heatmap(current_user)
    end
    
    def payment_heatmap
      PayrollData.payment_heatmap(current_user)
    end
  end
end
