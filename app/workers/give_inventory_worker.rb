# frozen_string_literal: true

# Queues giving inventory jobs
class GiveInventoryWorker
  include Sidekiq::Worker

  def perform(inventory_id, avatar_key)
    puts 'queuing give inventory'
    InventorySlRequest.give_inventory(inventory_id, avatar_key)
  end
end
