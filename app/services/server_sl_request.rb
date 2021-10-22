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

  # rubocop:disable Layout/MultilineOperationIndentation, Style/StringConcatenation
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def self.generate_message(avatar_name, expiration_date)
    if expiration_date > Time.current
      "Hello #{avatar_name}. Thank you for using SLapp Data. " +
                'This is a gentle reminder your SLapp Data account will ' +
                'expire in ' +
                distance_of_time_in_words(Time.current, expiration_date) +
                '. Please visit our service center at ' +
                "#{Settings.default.visit_us_slurl} to pay and prevent " +
                'any loss of data and services.'
    elsif expiration_date > 7.days.ago
      "Hello #{avatar_name}. Thank you for using SLapp Data. " +
                'Your SLapp Data account expired ' +
                distance_of_time_in_words(Time.current, expiration_date) +
                'ago. Please visit our service center at ' +
                "#{Settings.default.visit_us_slurl} to pay and prevent any " +
                'further loss of data and services.'
    else
      'Your SLapp Data account will be inactivated soon due to ' +
                'nonpayment. Your data will be saved for one year, but all ' +
                'your objects will be deleted soon. If you would like to ' +
                'reactivate your account, visit us at  ' +
                "#{Settings.default.visit_us_slurl} .and make a payment."
    end
  end
  # rubocop:enable Layout/MultilineOperationIndentation, Style/StringConcatenation
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def self.account_payment_message(avatar_name, avatar_key, expiration_date)
    server = User.where(role: :owner).sample.servers.sample
    RestClient::Request.execute(
      url: "#{server.url}/message_user",
      method: :post,
      payload: {
        avatar_name: avatar_name,
        avatar_key: avatar_key,
        message: generate_message(avatar_name, expiration_date)
      }.to_json,
      content_type: :json,
      accept: :json,
      verify_ssl: false,
      headers: request_headers(server)
    ) unless Rails.env.development?
  end
end
