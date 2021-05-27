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
  
  def self.send_money(object, avatar_name, avatar_key, amount)
    RestClient::Request.execute(
      url: "#{object.url}/give_money",
      method: :post,
      payload: { avatar_name: avatar_name, amount: amount }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(object)
    ) unless Rails.env.development?
  end
end
