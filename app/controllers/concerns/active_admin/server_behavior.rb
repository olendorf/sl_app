# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module ServerBehavior
    extend ActiveSupport::Concern

    def self.included(base)
      base.controller do
        def update
          if params['rezzable_server']['inventories_attributes']
            InventorySlRequest.batch_destroy(
              extract_deleted_inventories(params.to_unsafe_h)
            )
          end
          RezzableSlRequest.update_web_object!(
            resource,
            params[resource.class.name.underscore.gsub('/', '_')]
          )
          super
        rescue RestClient::ExceptionWithResponse => e
          flash[:error] = t('active_admin.web_object.update.failure',
                            message: e.response)
          parts = request.url.split('/')[3, 2]
          redirect_back(fallback_location: send("#{parts.first}_servers_path"))
        end

        def destroy
          RezzableSlRequest.derez_web_object!(resource)
          super
        rescue RestClient::ExceptionWithResponse => e
          flash[:error] = t('active_admin.web_object.destroy.failure',
                            message: e.response)
          parts = request.url.split('/')[3, 2]
          redirect_back(fallback_location: send("#{parts.first}_servers_path"))
        end

        def extract_deleted_inventories(params)
          data = params['rezzable_server']['inventories_attributes'].collect do |_key, value|
            value
          end
          ids = []
          data.each do |inv|
            ids << inv['id'].to_i if inv['_destroy'] == '1'
          end
          ids
        end
      end
    end
  end
end
