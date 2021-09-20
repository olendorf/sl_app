# frozen_string_literal: true

module Analyzable
  class ParcelState < ApplicationRecord
    belongs_to :parcel, class_name: 'Analyzable::Parcel'
    belongs_to :user

    enum state: %i[open for_sale occupied]
    
    def duration
      end_time = self.closed_at.nil? ? Time.current : self.closed_at
      (end_time - created_at).to_i
    end
  end
end
