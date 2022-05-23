# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module InventoryBehavior
    extend ActiveSupport::Concern

    def self.included(base)
      base.instance_eval do
        member_action :give, method: :post do
          InventorySlRequest.give_inventory(resource.id, params['avatar_name'])
          flash.notice = "Inventory given to #{params['avatar_name']}"
          if resource.owner_can_copy?
            redirect_back(
              fallback_location: send("#{self.class.module_parent.name.downcase}_dashboard_path")
            )
          else
            resource.destroy
            redirect_to send(
              "#{self.class.module_parent.name.downcase}_server_path",
              resource.server
            )
          end
        rescue RestClient::ExceptionWithResponse => e
          flash[:error] = t('active_admin.inventory.give.failure',
                            message: e.response)
          redirect_back(fallback_location:
                            send(
                              "#{self.class.module_parent.name.downcase}_inventories_path"
                            ))
        end
      end
    end
  end
end
