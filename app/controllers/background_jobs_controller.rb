# frozen_string_literal: true

# Handles requests to setup background jobs.
# class BackgroundJobsController < ApplicationController
#   def give_inventory
#     inventory = Analyzable::Inventory.find(params['inventory_id'])
#     GiveInventoryWorker.perform_async(params['avatar_key'], inventory.id)
#     message = "Your purchase #{inventory.inventory_name} has been queued for redelivery."
#     flash[:notice] = message
#     redirect_back(fallback_location: root_path)
#   end
# end
