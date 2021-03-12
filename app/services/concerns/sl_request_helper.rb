# frozen_string_literal: true

# Helpers for creating requests into SL objects
module SlRequestHelper
  extend ActiveSupport::Concern

  included do
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
end
