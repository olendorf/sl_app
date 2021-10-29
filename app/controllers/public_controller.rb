class PublicController < ApplicationController
  def available_parcels
    @owner = User.find_by_avatar_key(params['avatar_key'])
    @parcels = Analyzable::Parcel.where(current_state: "for_sale", user_id: @owner.id)
  end

  def my_parcels
  end

  def purchases
  end
end
