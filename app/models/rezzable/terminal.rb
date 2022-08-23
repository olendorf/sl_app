# frozen_string_literal: true

module Rezzable
  # Class for rezzable terminals in SL
  class Terminal < ApplicationRecord
    acts_as :abstract_web_object

    include RezzableBehavior
    include TransactableBehavior

    OBJECT_WEIGHT = 10_000

    # rubocop:disable Style/RedundantSelf
    def response_data
      { api_key: self.reload.api_key,
        object_name: self.object_name,
        description: self.description,
        settings: {
          api_key: self.reload.api_key, 
          object_name: self.object_name,
          description: self.description
        } }
    end
    # rubocop:enable Style/RedundantSelf

    def transaction_category
      'account'
    end

    def transaction_description(transaction)
      "Account payment from #{transaction.target_name}."
    end
  end
end
