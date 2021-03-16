# frozen_string_literal: true

module Analyzable
  # Records monetary transactions
  class Transaction < ApplicationRecord
    has_paper_trail

    belongs_to :user

    belongs_to :web_object, optional: true

    enum category: %i[other account donation tip sale tier share]
  end
end
