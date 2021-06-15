# frozen_string_literal: true

module Analyzable
  class Session < ApplicationRecord
    belongs_to :sessionable, polymorphic: true
    belongs_to :user
    has_many :transactions
  end
end
