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
  
  def self.batch_destroy(*ids)
    puts ids.class.name
    puts ids.first
    ids.first.each do |id| 
      puts "ID = #{id}"
      delete_inventory(Analyzable::Inventory.find(id)) 
    end
  end
  
end