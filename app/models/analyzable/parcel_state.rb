# frozen_string_literal: true

module Analyzable
  # Keeps track of parcel states and their duration to allow
  # analysis of parcel use, turnover etc.
  class ParcelState < ApplicationRecord
    belongs_to :parcel, class_name: 'Analyzable::Parcel'
    belongs_to :user

    enum state: %i[open for_sale occupied]

    def duration
      end_time = closed_at.nil? ? Time.current : closed_at
      (end_time - created_at).to_i
    end
  end
end
