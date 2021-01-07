# frozen_string_literal: true

module Api
  module V1
    # Controller for API requests from SL
    class UsersController < Api::V1::ApiController
      before_action :find_user, except: :create

      def create
        authorize User

        @new_user = User.new(
          avatar_name: parsed_params['avatar_name'],
          avatar_key: parsed_params['avatar_key'],
          password: parsed_params['password'],
          password_confirmation: parsed_params['password_confirmation']
        )
        @new_user.save!
        render json: {
          message: t('api.user.create.success', url: Settings.default.site_url)
        }, status: :created
      end

      def update
        authorize @requesting_object

        @user.update!(parsed_params)

        render json: {
          message: t('api.user.update.success')
        }, status: :ok
      end

      def show
        authorize @requesting_object

        render json: {
          data: {
            avatar_name: @user.avatar_name,
            avatar_key: @user.avatar_key,
            role: @user.role,
            account_level: @user.account_level,
            expiration_date: @user.expiration_date.strftime('%B %-d, %Y')
          }
        }, status: :ok
      end

      def destroy
        authorize @requesting_object

        @user.destroy!

        render json: {
          message: t('api.user.destroy.success')
        }, status: :ok
      end

      private

      def parsed_params
        JSON.parse(request.raw_post)
      end

      def find_user
        @user = if action_name == 'show' || action_name == 'destroy'
                  User.find_by_avatar_key(params['avatar_key'])
                else
                  User.find_by_avatar_key(parsed_params['avatar_key'])
                end
      end
    end
  end
end
