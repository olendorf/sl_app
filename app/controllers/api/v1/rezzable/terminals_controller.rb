# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Controllre for request for in world Rezzable Terminals
      class TerminalsController < Api::V1::AbstractWebObjectsController
        def update
          add_transaction_to_user if @atts['transactions_attributes']
          enrich_atts if @atts['transactions_attributes']
          super
        end

        private

        def enrich_atts
          @message = I18n.t('api.terminal.payment.success')
          @atts['transactions_attributes'][
            0]['category'] = 'account'
          @atts['transactions_attributes'][
            0]['source_key'] = @requesting_object.object_key
          @atts['transactions_attributes'][
            0]['source_name'] = @requesting_object.object_name
          @atts['transactions_attributes'][
            0]['source_type'] = 'terminal'
          @atts['transactions_attributes'][
            0]['description'] = 'Account payment from '\
                                "#{@atts['transactions_attributes'][0]['target_name']}."
        end

        def add_transaction_to_user
          target_user = User.find_by_avatar_key(
            @atts['transactions_attributes'][0]['target_key']
          )
          target_user.transactions << ::Analyzable::Transaction.new(
            amount: @atts['transactions_attributes'][0]['amount'] * -1,
            target_key: @requesting_object.user.avatar_key,
            target_name: @requesting_object.user.avatar_name,
            source_key: @requesting_object.object_key,
            source_name: @requesting_object.object_name,
            source_type: 'terminal',
            category: 'account',
            description: 'Account payment.'
          )
        end
      end
    end
  end
end
