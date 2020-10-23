# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
##
# Generates headers sent from Second Life. If a sending object is provided
# then those values are used unless overridden in the options. If no sending
# option is used then random values are used, unless overriden in the options.
#
# @param sending_object [Rezzable::WebObject]
# @param opts[Hash]
# @options api_key[String] an alternative to the default api key
# @option auth_time[String] an alternative to the current epoch time as string.
# @option digest[String] an alternative to a generated digest.

def headers(sending_object = nil, opts = {})
  sending_object = sending_object.attributes unless sending_object.is_a? Hash
  sending_object = sending_object.with_indifferent_access
  unless opts[:avatar_key]
    sending_object[:avatar_key] = User.find(sending_object[:user_id]).avatar_key
  end
  opts[:auth_time] ||= Time.now.to_i
  digest = Digest::SHA1.hexdigest(
    opts[:auth_time].to_s + api_key(sending_object, opts)
  )
  headers = {
    'HTTP_X_SECONDLIFE_SHARD' => 'Production',
    'HTTP_X_AUTH_TIME' => opts[:auth_time],
    'HTTP_X_AUTH_DIGEST' => digest
  }

  headers['HTTP_X_SLAPP_PASSWORD'] = opts[:password] if opts[:password]
  position = JSON.parse(sending_object[:position])
  headers['HTTP_X_SECONDLIFE_LOCAL_POSITION'] = "(#{position['x']}, " \
                                                "#{position['y']}, " \
                                                "#{position['z']})"

  second_life_header_map.each do |header, attr|
    headers[header] = if sending_object
                        opts[attr].nil? ? sending_object[attr] : opts[attr]
                      else
                        opts[attr]
                      end
  end
  headers
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

private

##
# Returns the appropriate api_key
#
# @param sending_object [Rezzable::WebObject]
# @param opts [Hash] see above, only used option is :api_key
# @return [String] the desired api_key
def api_key(sending_object = nil, opts = {})
  return opts[:api_key] if opts[:api_key]
  return sending_object[:api_key] if sending_object && sending_object[:api_key]

  Settings.default.web_object.api_key
end

##
# Maps second life header names onto the corresponding attribute name
# in Rezzable:WebObject
#
# @return [Hash]
def second_life_header_map
  {
    'HTTP_X_SECONDLIFE_OBJECT_NAME' => :object_name,
    'HTTP_X_SECONDLIFE_OBJECT_KEY' => :object_key,
    'HTTP_X_SECONDLIFE_REGION' => :region,
    # 'HTTP_X_SECONDLIFE_LOCAL_POSITION' => :position,
    'HTTP_X_SECONDLIFE_OWNER_KEY' => :avatar_key
  }
end
