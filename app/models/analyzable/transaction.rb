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
    belongs_to :session, optional: true
    belongs_to :inventory, class_name: 'Analyzable::Inventory', optional: true
    belongs_to :product, class_name: 'Analyzable::Product', optional: true
    belongs_to :parcel, class_name: 'Analyzable::Parcel', optional: true

    # belongs_to :web_object, class_name: 'AbstractWebObject', optional: true

    enum category: %i[other account donation tip sale tier share]
  end
end
