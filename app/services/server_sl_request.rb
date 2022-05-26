# frozen_string_literal: true

# Handles requests to object in SL
# from Servers
class ServerSlRequest
  include SlRequestHelper
  extend ActionView::Helpers::DateHelper

  def self.send_money(server, avatar_name, amount)
    server = Rezzable::Server.find(server) if server.is_a? Integer
    RestClient::Request.execute(
      url: "#{server.url}/services/give_money",
      method: :post,
      payload: { avatar_name: avatar_name, amount: amount }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end

  def self.message_user(server_id, avatar_name, avatar_key, message)
    server = Rezzable::Server.find(server_id)
    RestClient::Request.execute(
      url: "#{server.url}/message_user",
      method: :post,
      payload: {
        avatar_name: avatar_name,
        avatar_key: avatar_key,
        message: message
      }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end

  def self.pay_user(server_id, avatar_name, avatar_key, amount)
    server = Rezzable::Server.find(server_id)
    RestClient::Request.execute(
      url: "#{server.url}/pay_user",
      method: :put,
      payload: {
        avatar_name: avatar_name,
        avatar_key: avatar_key,
        amount: amount
      }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end
end
