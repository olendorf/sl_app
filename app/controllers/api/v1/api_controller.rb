class Api::V1::ApiController < ApplicationController
  
  include Api::ExceptionHandler
  include Api::ResponseHandler
  
  before_action :load_requesting_object, except: [:create]
  before_action :validate_package
  
  include Pundit
  
  after_action :verify_authorized

  def policy(record)
    policies[record] ||=
      "#{controller_path.classify}Policy".constantize.new(pundit_user, record)
  end

  
  private
  
  def pundit_user
    User.find_by_avatar_key!(request.headers['HTTP_X_SECONDLIFE_OWNER_KEY'])
  end
  
  def load_requesting_object
    @requesting_object = AbstractWebObject.find_by_object_key(
      request.headers['HTTP_X_SECONDLIFE_OBJECT_KEY']
    ).actable
  end
  
  def validate_package
    
    raise(
      ActionController::BadRequest, I18n.t('errors.auth_time')
    ) unless (Time.now.to_i - auth_time).abs < 30
    
    raise(
      ActionController::BadRequest, I18n.t('errors.auth_digest')
    ) unless auth_digest == create_digest
  end
  
  def api_key
    return Settings.default.web_object.api_key if action_name.downcase == 'create'
  
    @requesting_object.api_key
  end
  
  def auth_digest
    request.headers['HTTP_X_AUTH_DIGEST']
  end

  def auth_time
    return 0 unless request.headers['HTTP_X_AUTH_TIME']

    request.headers['HTTP_X_AUTH_TIME'].to_i
  end

  def create_digest
    Digest::SHA1.hexdigest(auth_time.to_s + api_key)
  end
end
