# frozen_string_literal: true

module Api
  module V1
    # Controller for API requests from SL
    class UsersController < Api::V1::ApiController
      before_action :load_user, except: %i[index create]

      def create
        authorize User

        @user = User.new(parsed_params.except('amount'))
        @user.save!

        add_transaction if parsed_params['amount'].positive?

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
        adjust_expiration_date if parsed_params['account_level']
        handle_payment if parsed_params['amount']
        @user.update!(parsed_params.except('amount'))
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

      def handle_payment
        more_time = (parsed_params['amount'].to_f / (
                                  Settings.default.account.monthly_cost * @user.account_level))
        @user.expiration_date = @user.expiration_date + more_time.to_i.months
        @user.save!
        add_transaction
      end

      def adjust_expiration_date
        @user.expiration_date = Time.now + (
              @user.expiration_date.to_i - Time.now.to_i
            ) * (@user.account_level.to_f / parsed_params['account_level'])
      end

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

      def add_transaction
        load_requesting_object unless @requesting_object
        @requesting_object.user.transactions << Analyzable::Transaction.new(
          amount: parsed_params['amount'],
          description: 'Account payment',
          source_key: @requesting_object.object_key,
          source_name: @requesting_object.object_name,
          source_type: @requesting_class.class.name,
          category: 'account',
          target_key: parsed_params['avatar_key'],
          target_name: parsed_params['avatar_name']
        )
      end

      def pundit_user
        return User.where(role: 'owner').first if action_name == 'create'

        User.find_by_avatar_key!(request.headers['HTTP_X_SECONDLIFE_OWNER_KEY'])
      end
    end
  end
end
