# frozen_string_literal: true

module Analyzable
  # Models work sessons by the employees.
  class WorkSession < ApplicationRecord
    belongs_to :employee, class_name: 'Analyzable::Employee'
  end
end
