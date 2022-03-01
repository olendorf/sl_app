# frozen_string_literal: true

module Analyzable
  # Models the employees that can use the time cop
  class Employee < ApplicationRecord
    before_update :clock, if: :work_session

    belongs_to :user
    has_many :work_sessions, class_name: 'Analyzable::WorkSession'

    attr_accessor :work_session

    validates :avatar_key, uniqueness: {
      scope: :user_id,
      message: 'This avatar is already an employee.'
    }

    def clock
      clock_in unless on_the_clock?
      clock_out if on_the_clock?
    end

    def clock_in
      Analyzable::WorkSession.create(employee_id: id)
      self.work_session = nil
    end

    def clock_out
      self.work_session = nil
      stopped_at = Time.current
      duration = (stopped_at - work_sessions.last.created_at) / 1.hour.to_f
      pay = hourly_pay * duration
      work_sessions.last.update(stopped_at: stopped_at, duration: duration, pay: pay)
    end

    def on_the_clock?
      return false if work_sessions.size.zero?

      work_sessions.last.stopped_at.nil?
    end
  end
end
