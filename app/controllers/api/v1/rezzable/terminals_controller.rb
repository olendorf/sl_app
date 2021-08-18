# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Controllre for request for in world Rezzable Terminals
      class TerminalsController < Api::V1::AbstractWebObjectsController
        # def update
        #   if @atts['transactions_attributes']
        #     target_user = User.find_by_avatar_key(
        #       @atts['transactions_attributes'][0]['target_key']
        #     )
        #     add_transaction_to_user(target_user)
        #     extend_user_expiration_date(target_user)
        #     @message = I18n.t('api.terminal.payment.success')
        #   end
        #   super
        # end

        private

        def extend_user_expiration_date(target_user)
          target_user.expiration_date = target_user.expiration_date + (
              @atts['transactions_attributes'][0]['amount'] / (
                Settings.default.account.monthly_cost * target_user.account_level
              ).to_f
            ) * 1.month.seconds
          target_user.save
        end

        def add_transaction_to_user(target_user)
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
