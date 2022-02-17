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
                              message: "This avatar is already an employee." 
    }
    
    
    def clock
      clock_in unless on_the_clock?
      clock_out if on_the_clock?
    end
    
    def clock_in
      Analyzable::WorkSession.create(employee_id: self.id)
      self.work_session = nil
    end 
    
    def clock_out
      self.work_session = nil
      stop_time = Time.current
      duration = (stop_time - self.work_sessions.last.created_at)/1.hour
      pay = self.hourly_pay * duration
      self.work_sessions.last.update(stop_time: stop_time, duration: duration, pay: pay)
    end
    
    def on_the_clock?
      return false if self.work_sessions.size.zero?
      self.work_sessions.last.stop_time.nil?
    end
  end
end
