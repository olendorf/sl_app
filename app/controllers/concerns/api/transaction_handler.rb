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

      # def handle_splits(base_transaction)
      #   splits = @requesting_object.splits + @requesting_object.user.splits
      #   splits.each do |split|
      #     @requesting_object.user.transactions << Analyzable::Transaction.new(
      #       amount: (-1 * parsed_params['account_payment'] * split.percent.to_f / 100).round,
      #       source_key: split.splittable.splittable_key,
      #       source_name: split.splittable.splittable_name,
      #       source_type: split.splittable.class.name,
      #       transaction_id: base_transaction.id,
      #       category: base_transaction.category,
      #       description: "Split from #{base_transaction.description}",
      #       target_name: split.target_name,
      #       target_key: split.target_key
      #     )
      #     target_user = User.find_by_avatar_key(split.target_key)
      #     send_payment(split, parsed_params['account_payment'])
      #     add_split_to_target(split, target_user, base_transaction) if target_user
      #   end
      # end

      # def send_payment(split, amount)
      #   RestClient::Request.execute(
      #     url: @requesting_object.url,
      #     method: :put,
      #     payload: {
      #       amount: (amount * split.percent.to_f / 100).round,
      #       target_key: split.target_key
      #     }.to_json,
      #     verify_ssl: false,
      #     headers: request_headers
      #   ) unless Rails.env.development?
      # end

      # def request_headers
      #   auth_time = Time.now.to_i
      #   {
      #     content_type: :json,
      #     accept: :json,
      #     verify_ssl: false,
      #     params: {
      #       auth_digest: auth_digest,
      #       auth_time: auth_time
      #     }
      #   }
      # end

      # def add_split_to_target(split, target_user, base_transaction)
      #   target_user.transactions << Analyzable::Transaction.new(
      #     amount: (parsed_params['account_payment'] * split.percent.to_f / 100).round,
      #     source_key: split.splittable.splittable_key,
      #     source_name: split.splittable.splittable_name,
      #     source_type: split.splittable.class.name,
      #     category: base_transaction.category,
      #     description: "Split from #{base_transaction.description}",
      #     target_name: @user.avatar_name,
      #     target_key: @user.avatar_key
      #   )
      # end
    end
  end
end
