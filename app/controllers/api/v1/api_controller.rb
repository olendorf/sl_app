# frozen_string_literal: true

module Api
  module V1
    # Base API controller class. All sl api controllers ultimately
    # should inherit from this class. Contains many needed functions.
    class ApiController < ApplicationController
      include Api::ExceptionHandler
      include Api::ResponseHandler

      before_action :load_requesting_object, except: [:create]
      before_action :validate_package

      include Pundit

      after_action :verify_authorized

      def policy(record)
        policies[record] ||=
          "#{controller_path.classify}Policy".constantize.new(pundit_user, record)
      end


      private
      
            
      def api_key
        return Settings.default.web_object.api_key if action_name.downcase == 'create'

        @requesting_object.api_key
      end

      def parsed_params
        JSON.parse(request.raw_post)
      end

      def pundit_user
        User.find_by_avatar_key!(request.headers['HTTP_X_SECONDLIFE_OWNER_KEY'])
      end

      def load_requesting_object
        @requesting_object = AbstractWebObject.find_by_object_key(
          request.headers['HTTP_X_SECONDLIFE_OBJECT_KEY']
        ).actable
      end

      def validate_package
        # puts auth_digest
        # puts create_digest
        # puts api_key
        
        
        unless (Time.now.to_i - auth_time).abs < 30
          raise(
            ActionController::BadRequest, I18n.t('errors.auth_time')
          )
        end

        # rubocop:disable Style/GuardClause
        unless auth_digest == create_digest
          raise(
            ActionController::BadRequest, I18n.t('errors.auth_digest')
          )
        end
        # rubocop:enable Style/GuardClause
      end



      def auth_digest
        request.headers['HTTP_X_AUTH_DIGEST']
      end

      def auth_time
        return 0 unless request.headers['HTTP_X_AUTH_TIME']

        request.headers['HTTP_X_AUTH_TIME'].to_i
      end

      def create_digest
        Digest::SHA1.hexdigest(auth_time.to_s + api_key)
      end
    end
  end
end
