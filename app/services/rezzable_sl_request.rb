# frozen_string_literal: true

# Handles requests to object in SL
class RezzableSlRequest
  include SlRequestHelper

  def self.derez_web_object!(resource)
    RestClient::Request.execute(
      url: resource.url,
      method: :delete,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(resource)
    ) unless Rails.env.development?
  end

  def self.update_web_object!(resource, params)
    RestClient::Request.execute(
      url: resource.url,
      method: :put,
      payload: params.to_json,
      verify_ssl: false,
      headers: request_headers(resource)
    ) unless Rails.env.development?
  end
end
