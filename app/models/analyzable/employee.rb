# frozen_string_literal: true

module Analyzable
  # Models the employees that can use the time cop
  class Employee < ApplicationRecord
    belongs_to :user
    has_many :work_sessions, class_name: 'Analyzable::WorkSession'
  end
end
