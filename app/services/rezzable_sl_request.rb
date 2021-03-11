# frozen_string_literal: true

class RezzableSlRequest
  include SlRequestHelper
  def self.derez_web_object!(resource)
    unless Rails.env.development?
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
      end
    end
  end

  def self.update_web_object!(resource, params)
    unless Rails.env.development?
      begin
        RestClient::Request.execute(
          url: resource.url,
          method: :put,
          payload: params.to_json,
          verify_ssl: false,
          headers: request_headers(resource)
        )
      rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.web_object.update.failure',
                          message: e.response)
      end
    end
  end
end
