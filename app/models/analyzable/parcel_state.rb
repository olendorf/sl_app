# frozen_string_literal: true

module Analyzable
  class ParcelState < ApplicationRecord
    belongs_to :parcel, class_name: 'Analyzable::Parcel'
    belongs_to :user

    enum state: %i[open for_sale occupied]
  end
end
