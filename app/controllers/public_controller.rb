# frozen_string_literal: true

# Controller for public pages.
class PublicController < ApplicationController
  # include ExceptionHandler

  def available_parcels
    @owner = User.find_by_avatar_key(params['avatar_key'])
    @parcels = Analyzable::Parcel.where(
      current_state: 'for_sale', user_id: @owner.id
    ).includes(:user).page(params[:page]).per(9)
  end

  def my_parcels
    authorize_request
    @owner = requesting_object.user
    @renter = Avatar.find_by_avatar_key(params['renter_key'])
    @parcels = Analyzable::Parcel.where(
      owner_key: params['renter_key'],
      user_id: @owner.id
    ).includes(:user).page(params[:page]).per(9)
  end

  def my_purchases
    authorize_request
    @user = User.find_by_avatar_key(params['avatar_key'])
    @purchases = Analyzable::Transaction.where(
      category: 'sale', target_key: params['avatar_key']
    ).includes([:inventory]).order(:created_at).reverse_order.page(params[:page]).per(18)
  end

  def authorize_request(time_limit = 60)
    return if Rails.env.development?

    unless (Time.now.to_i - auth_time).abs < time_limit
      render 'errors/bad_request', status: :bad_request and return
    end

    render 'errors/not_found', status: :not_found and return unless auth_digest == create_digest
  end

  def create_digest
    Digest::SHA1.hexdigest(auth_time.to_s + api_key)
  end

  def auth_digest
    params['auth_digest']
  end

  def api_key
    requesting_object.api_key
  end

  def auth_time
    return 0 unless params['auth_time']

    params['auth_time'].to_i
  end

  def requesting_object
    @requesting_object ||= AbstractWebObject.find_by_object_key(
      params['object_key']
    )
    @requesting_object
  end
end
