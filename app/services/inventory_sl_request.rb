class InventorySlRequest
  include SlRequestHelper
  
  def self.delete_inventory(inventory)
    server = inventory.server
    begin
      RestClient::Request.execute(
        url: "#{server.url}/inventory/#{URI.encode(inventory.inventory_name)}",
        method: :delete,
        content_type: :json,
        accept: :json,
        verify_ssl: false,
        headers: request_headers(server)
      )
    rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.inventory.delete.failure',
                          message: e.response)
    end unless Rails.env.development?
  end
  
  # private  
  
  #   def self.auth_digest(resource, auth_time)
  #     Digest::SHA1.hexdigest(auth_time.to_s + resource.api_key)
  #   end

  #   def self.request_headers(resource)
  #     auth_time = Time.now.to_i
  #     {
  #       content_type: :json,
  #       accept: :json,
  #       verify_ssl: false,
  #       params: {
  #         auth_digest: auth_digest(resource, auth_time),
  #         auth_time: auth_time
  #       }
  #     }
  #   end
end