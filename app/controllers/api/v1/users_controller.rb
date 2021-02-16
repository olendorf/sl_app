# frozen_string_literal: true

module Api
  module V1
    # Controller for API requests from SL
    class UsersController < Api::V1::ApiController
      before_action :load_user, except: %i[index create]

      def create
        authorize User

        @user = User.new(
          parsed_params.except('account_payment')
        )
        @user.save!

        handle_transactions if parsed_params['account_payment'].positive?

        render json: {
          message: I18n.t('api.user.create.success', url: Settings.default.site_url),
          data: user_data
        }, status: :created
      end

      def show
        authorize @requesting_object
        render json: {
          data: user_data
        }, status: :ok
      end

      def update
        authorize @requesting_object
        # adjust_expiration_date if parsed_params['account_level']
        handle_transactions if parsed_params['account_payment']
        @user.update!(parsed_params)
        
        render json: {
          message: I18n.t('api.user.update.success'),
          data: user_data
        }, status: :ok
      end

      def destroy
        authorize @requesting_object
        @user.destroy!
        render json: {
          message: I18n.t('api.user.destroy.success')
        }, status: :ok
      end

      private

      def load_user
        @user = User.find_by_avatar_key(params['avatar_key'])
      end

      def user_data
        return { monthly_cost: Settings.default.account.monthly_cost } unless @user

        {
          monthly_cost: Settings.default.account.monthly_cost,
          avatar_name: @user.avatar_name,
          avatar_key: @user.avatar_key,
          time_left: @user.time_left,
          account_level: @user.account_level
        }
      end
      
      def handle_transactions
        load_requesting_object unless @requesting_object
        base_transaction = add_transaction
        handle_splits(base_transaction)
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
        return @requesting_object.user.transactions.last
      end
      
      def handle_splits(base_transaction)
        splits = @requesting_object.splits + @requesting_object.user.splits
        splits.each do |split|
          @requesting_object.user.transactions << Analyzable::Transaction.new(
              amount: -1 * parsed_params['account_payment'] * split.percent.to_f/100,
              source_key: split.splittable.splittable_key,
              source_name: split.splittable.splittable_name,
              source_type: split.splittable.class.name,
              transaction_id: base_transaction.id,
              category: base_transaction.category,
              description: "Split from #{base_transaction.description}",
              target_name: split.target_name,
              target_key: split.target_key
            )
          if targer_user = User.find_by_avatar_key(split.target_key)
            targer_user.transactions << Analyzable::Transaction.new(
              amount: parsed_params['account_payment'] * split.percent.to_f/100,
              source_key: split.splittable.splittable_key,
              source_name: split.splittable.splittable_name,
              source_type: split.splittable.class.name,
              category: base_transaction.category,
              description: "Split from #{base_transaction.description}",
              target_name: @user.avatar_name,
              target_key: @user.avatar_key
            )
          end
            
        end
      end

      def pundit_user
        return User.where(role: 'owner').first if action_name == 'create'

        User.find_by_avatar_key!(request.headers['HTTP_X_SECONDLIFE_OWNER_KEY'])
      end
    end
  end
end
