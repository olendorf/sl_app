# frozen_string_literal: true

module Api
  module V1
    # Controller for API requests from SL
    class UsersController < Api::V1::ApiController
      include Api::TransactionHandler

      before_action :load_user, except: %i[index create]

      def create
        authorize [:api, :v1, User]

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
        authorize [:api, :v1, @requesting_object]
        render json: {
          data: user_data
        }, status: :ok
      end

      def update
        authorize [:api, :v1, @requesting_object]
        # adjust_expiration_date if parsed_params['account_level']
        # handle_transactions if parsed_params['account_payment']
        @user.update!(parsed_params.merge({ requesting_object: @requesting_object }))

        render json: {
          message: I18n.t('api.user.update.success'),
          data: user_data
        }, status: :ok
      end

      def destroy
        authorize [:api, :v1, @requesting_object]
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
          payment_schedule: @user.payment_schedule,
          avatar_name: @user.avatar_name,
          avatar_key: @user.avatar_key,
          role: @user.role,
          time_left: @user.time_left,
          account_level: @user.account_level
        }
      end
      
 

      def pundit_user
        return User.where(role: 'owner').first if action_name == 'create'

        User.find_by_avatar_key!(request.headers['HTTP_X_SECONDLIFE_OWNER_KEY'])
      end
    end
  end
end
