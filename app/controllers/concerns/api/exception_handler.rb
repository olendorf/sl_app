# frozen_string_literal: true

require 'active_support/concern'

module Api
  # Handles Exceptions thrown in the API
  module ExceptionHandler
    extend ActiveSupport::Concern

    included do
      # rescue_from ArgumentError do |e|
      #   json_response({ message: e.message }, :bad_request)
      # end

      # rescue_from ActiveRecord::RecordNotFound do |e|
      #   json_response({ message: e.message }, :not_found)
      # end

      # rescue_from Pundit::NotAuthorizedError do |_e|
      #   json_response({ message: 'You are unauthorized to do that' }, :unauthorized)
      # end

      rescue_from ActiveRecord::RecordInvalid do |e|
        json_response({ message: e.message }, :unprocessable_entity)
      end

      rescue_from ActionController::BadRequest do |e|
        json_response({ message: e.message }, :bad_request)
      end

      rescue_from Pundit::NotAuthorizedError do |e|
        json_response({ message: e.message }, :forbidden)
      end
    end
  end
end
