# frozen_string_literal: true

# Handles data processing for parcels
class PayrollData
  include DataHelper

  def self.payroll_timeline(current_user)
    work_sessions = current_user.work_sessions.order(:created_at)
    dates = time_series_months(work_sessions.minimum(:created_at) - 2.days, Time.current)
    payments = Array.new(dates.size, 0)
    hours = Array.new(dates.size, 0)
    work_sessions.each do |w|
      index = dates.index(w.created_at.strftime('%B %Y'))
      payments[index] += w.pay unless w.pay.nil?
      hours[index] += w.duration unless w.duration.nil?
    end 
    {dates: dates, hours: hours, payments: payments}
  end
  
  def self.hours_heatmap(current_user)
    work_sessions = current_user.work_sessions.where('analyzable_work_sessions.created_at >= ?', 1.month.ago)
    data = []
    (0..23).each { |h| (0..6).each { |d| data << [d, h, 0] } }
    work_sessions.each do |work_session|
      h = work_session.created_at.strftime('%k').to_i
      d = work_session.created_at.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + (work_session.duration) unless work_session.duration.nil?
    end
    data
  end
  
  def self.payment_heatmap(current_user)
    work_sessions = current_user.work_sessions.where('analyzable_work_sessions.created_at >= ?', 1.month.ago)
    data = []
    (0..23).each { |h| (0..6).each { |d| data << [d, h, 0] } }
    work_sessions.each do |work_session|
      h = work_session.created_at.strftime('%k').to_i
      d = work_session.created_at.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + (work_session.pay) unless work_session.pay.nil?
    end
    data
  end
end
