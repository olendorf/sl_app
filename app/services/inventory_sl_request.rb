# frozen_string_literal: true

# Handles requests into SL to manage server inventory.
class InventorySlRequest
  include SlRequestHelper

  def self.delete_inventory(inventory)
    server = inventory.server
    # rubocop:disable Style/GuardClause
    unless Rails.env.development?
      begin
        RestClient::Request.execute(
          url: "#{server.url}/inventory/#{ERB::Util.url_encode(inventory.inventory_name)}",
          method: :delete,
          content_type: :json,
          accept: :json,
          verify_ssl: false,
          headers: request_headers(server)
        )
      rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.inventory.delete.failure',
                          message: e.response)
      end
    end
  end

  def self.batch_destroy(*ids)
    ids.first.each do |id|
      delete_inventory(Analyzable::Inventory.find(id))
    end
  end

  def self.move_inventory(inventory, server_id)
    server = Rezzable::Server.find(server_id)
    unless Rails.env.development?
      begin
        RestClient::Request.execute(
          url: "#{server.url}/inventory/#{ERB::Util.url_encode(inventory.inventory_name)}",
          method: :put,
          content_type: :json,
          accept: :json,
          payload: { server_key: server.object_key }.to_json,
          verify_ssl: false,
          headers: request_headers(server)
        )
      rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.inventory.delete.failure',
                          message: e.response)
      end
    end
  end
  # rubocop:enable Style/GuardClause
end
