# frozen_string_literal: true

require 'active_support/concern'

module Api
  #  Methods for handling transactions.
  module TransactionHandler
    extend ActiveSupport::Concern

    included do
      def handle_transactions
        load_requesting_object unless @requesting_object
        add_transaction
        # handle_splits(base_transaction)
      end

      def add_transaction
        @requesting_object.user.transactions << Analyzable::Transaction.new(
          amount: parsed_params['account_payment'],
          description: 'Account payment',
          source_key: @requesting_object.object_key,
          source_name: @requesting_object.object_name,
          source_type: @requesting_class.class.name,
          category: 'account',
          target_key: parsed_params['avatar_key'],
          target_name: parsed_params['avatar_name']
        )
        @requesting_object.user.transactions.last
      end
    end
  end
end
