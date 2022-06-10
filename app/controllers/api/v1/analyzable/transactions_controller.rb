# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Authorization for Transactions.
      class TransactionsController < Api::V1::AnalyzableController
        def create
          authorize [:api, :v1, @requesting_object]
          @requesting_object.user.transactions << ::Analyzable::Transaction.new(atts)
          render json: { message: 'Created' }, status: 201
        end
      end
    end
  end
end
