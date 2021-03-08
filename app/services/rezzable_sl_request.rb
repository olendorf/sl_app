class RezzableSlRequest
  def self.derez_web_object!(resource)
    begin
      RestClient::Request.execute(
        url: resource.url,
        method: :delete,
        content_type: :json,
        accept: :json,
        verify_ssl: false,
        headers: request_headers(resource)
      )
    rescue RestClient::ExceptionWithResponse => e
      flash[:error] = t('active_admin.web_object.delete.failure',
                        message: e.response)
    end unless Rails.env.development?
  end 
  
  def self.update_web_object!(resource, params)
    begin
      RestClient::Request.execute(
        url: resource.url,
        method: :put,
        payload: params[resource.class.name.underscore.gsub('/', '_')].to_json,
        verify_ssl: false,
        headers: request_headers(resource)
      )
    rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.web_object.update.failure',
                          message: e.response)
    end unless Rails.env.development?
  end
  
  private  
  
    def self.auth_digest(resource, auth_time)
      Digest::SHA1.hexdigest(auth_time.to_s + resource.api_key)
    end

    def self.request_headers(resource)
      auth_time = Time.now.to_i
      {
        content_type: :json,
        accept: :json,
        verify_ssl: false,
        params: {
          auth_digest: auth_digest(resource, auth_time),
          auth_time: auth_time
        }
      }
    end
end