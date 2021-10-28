# frozen_string_literal: true

# Handles requests to object in SL
# from Servers
class ServerSlRequest
  include SlRequestHelper
  extend ActionView::Helpers::DateHelper

  def self.send_money(server, avatar_name, amount)
    RestClient::Request.execute(
      url: "#{server.url}/give_money",
      method: :post,
      payload: { avatar_name: avatar_name, amount: amount }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end

  def self.message_user(server, avatar_name, avatar_key, message)
    RestClient::Request.execute(
      url: "#{server.url}/message_user",
      method: :post,
      payload: {
        avatar_name: avatar_name,
        avatar_key: avatar_key,
        message: message,
      }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end
end
