# frozen_string_literal: true

module Analyzable
  class Detection < ApplicationRecord
    belongs_to :visit, class_name: 'Analyzable::Visit'
  end
end
