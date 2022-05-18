# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module RezzableBehavior
    extend ActiveSupport::Concern

    def self.included(base)
      base.controller do
        def update
          begin
            RezzableSlRequest.update_web_object!(
              resource,
              params[resource.class.name.underscore.gsub('/', '_')]
            )
            super
          rescue RestClient::ExceptionWithResponse => e
            flash[:error] = t('active_admin.web_object.update.failure',
                              message: e.response)
            parts = request.url.split('/')[3, 2]
            redirect_back(fallback_location: send("#{parts.first}_#{parts.last}_path"))
          end
        end

        def destroy
          begin
            RezzableSlRequest.derez_web_object!(resource)
          rescue RestClient::ExceptionWithResponse => e
            flash[:error] = t('active_admin.web_object.destroy.failure',
                              message: e.response)
          ensure
            super   # No matter what, destory the object from the database.
          end
        end
      end
    end
  end
end
