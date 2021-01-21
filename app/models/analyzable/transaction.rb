# frozen_string_literal: true

module Analyzable
  # Records monetary transactions
  class Transaction < ApplicationRecord
    has_paper_trail

    belongs_to :user

    enum category: %i[other account tip sale tier share]
  end
end
