# frozen_string_literal: true

module Analyzable
  # Records monetary transactions
  class Transaction < ApplicationRecord
    has_paper_trail

    validates_presence_of :target_name
    validates_presence_of :target_key
    validates_numericality_of :amount, only_integer: true

    belongs_to :user
    
    belongs_to :transactable, polymorphic: true, class_name: 'Analyzable::Transaction'

    # belongs_to :web_object, class_name: 'AbstractWebObject', optional: true

    enum category: %i[other account donation tip sale tier share]
  end
end
