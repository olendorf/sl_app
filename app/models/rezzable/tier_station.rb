# frozen_string_literal: true

module Rezzable
  # Model for inworld Tier Stations.
  class TierStation < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include TransactableBehavior

    OBJECT_WEIGHT = 10

    def transaction_description(transaction)
      "Tier payment from #{transaction.target_name}."
    end

    def transaction_category
      'tier'
    end
  end
end
